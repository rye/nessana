require 'time'

require 'csv'
require 'nessana/detection'
require 'nessana/vulnerability'

module Nessana
	class Dump < Hash
		attr_reader :filters
		attr_reader :filename

		def initialize(filename = nil, filters = [])
			@filename, @filters = filename, filters

			if @filename
				if File.readable?(@filename)
					read_csv!
				else
					throw 'file not readable; sad face'
				end
			end
		end

		def -(other)
			other_plugin_ids = other.keys
			self_plugin_ids = keys

			other_detections = other.map do |plugin_id, vulnerability|
				vulnerability.detections.map do |detection|
					{
						plugin_id => detection.to_h
					}
				end
			end.flatten

			self_detections = map do |plugin_id, vulnerability|
				vulnerability.detections.map do |detection|
					{
						plugin_id => detection.to_h
					}
				end
			end.flatten

			detections = [other_detections, self_detections].flatten.uniq

			t0 = Time.now

			detections.each do |detection_entry|
				in_self = self_detections.include? detection_entry
				in_other = other_detections.include? detection_entry

				detection = detection_entry.values.first

				if in_self && in_other
					detection[:status] = :present
				elsif !in_self && in_other
					detection[:status] = :removed
				elsif in_self && !in_other
					detection[:status] = :added
				else
					detection[:status] = true
				end
			end

			puts "Detection status setting took #{Time.now - t0} seconds"

			added_plugin_ids = self_plugin_ids - other_plugin_ids
			deleted_plugin_ids = other_plugin_ids - self_plugin_ids
			all_plugin_ids = other_plugin_ids + added_plugin_ids

			throw 'something is wrong' unless (all_plugin_ids - added_plugin_ids) - other_plugin_ids == []
			throw 'something is wrong' unless (all_plugin_ids - deleted_plugin_ids) - self_plugin_ids == []

			mitigated_vulnerabilities = deleted_plugin_ids.map do |plugin_id|
				other[plugin_id]
			end

			new_vulnerabilities = added_plugin_ids.map do |plugin_id|
				self[plugin_id]
			end

			all_vulnerabilities = all_plugin_ids.map do |plugin_id|
				vulnerability = nil

				if !self[plugin_id]
					vulnerability = other[plugin_id].clone
				else
					vulnerability = self[plugin_id].clone
				end

				plugin_detections = detections.select do |detection_entry|
					detection_entry.keys.first == vulnerability[:plugin_id]
				end.map do |detection_entry|
					detection_entry.values.first
				end

				vulnerability.detections = plugin_detections.map do |detection|
					Detection.new(detection[:host], detection[:protocol], detection[:port], detection[:status])
				end

				vulnerability
			end

			all_vulnerabilities
		end

		def old_(other)
			removed_vulnerabilities = other.select do |plugin_id, _v|
				!self[plugin_id]
			end.map do |plugin_id, vulnerability|
				vulnerability
			end

			added_vulnerabilities = select do |plugin_id, _v|
				!other[plugin_id]
			end.map do |plugin_id, vulnerability|
				vulnerability
			end

			removed_detections = other.map do |plugin_id, other_vulnerability|
				# If we didn't already have an entry, all of the prior
				# detections have been added.
				if !self[plugin_id]
					[ plugin_id, { vulnerability: other_vulnerability, detections: other_vulnerability.detections } ]
				else
					current_vulnerability = self[plugin_id]
					change_in_detections = other_vulnerability.detections - current_vulnerability.detections
					[ plugin_id, { vulnerability: other_vulnerability, detections: change_in_detections } ]
				end
			end.to_h

			added_detections = map do |plugin_id, vulnerability|
				# If we didn't already have an entry in the prior dump, all of
				# our detections are new.
				if !other[plugin_id]
					[ plugin_id, { vulnerability: vulnerability, detections: vulnerability.detections } ]
				else
					prior_vulnerability = other[plugin_id]
					change_in_detections = vulnerability.detections - prior_vulnerability.detections
					[ plugin_id, { vulnerability: vulnerability, detections: change_in_detections } ]
				end
			end.to_h

			{
				:removed_vulnerabilities => removed_vulnerabilities,
				:new_vulnerabilities => added_vulnerabilities,
				:removed_detections => removed_detections.values,
				:new_detections => added_detections.values
			}
		end

		def read_csv!
			data = read_csv(filename)

			filtered_data = data.select do |plugin_id, vulnerability|
				!vulnerability.matches?(@filters)
			end

			merge!(filtered_data)
		end

		protected

		def read_csv(filename)
			dump_data = {}

			CSV.read(filename).each_with_index do |row, index|
				next if index == 0

				row_nessus_data = row[0..3] + row[7..-1]
				row_detection_data = row[4..6]

				plugin_id = row[0]

				unless !!dump_data[plugin_id]
					dump_data[plugin_id] = Vulnerability.new(*row_nessus_data)
				end

				row_detection = Detection.new(*row_detection_data)

				dump_data[plugin_id].add_detection(row_detection)
			end

			dump_data
		end
	end
end

require 'time'

require 'csv'
require 'fastcsv'
require 'tty-spinner'

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
					spinner = TTY::Spinner.new("[:spinner] Loading #{@filename}...", format: :dots_3)
					spinner.auto_spin

					read_csv!

					spinner.stop('Done!')
				else
					throw 'file not readable; sad face'
				end
			end
		end

		def -(other)
			other_plugin_ids = other.keys
			self_plugin_ids = keys

			other_detection_pairs = other.map do |plugin_id, vulnerability|
				vulnerability.detections.map do |detection|
					{ plugin_id => detection }
				end
			end

			other_detections = Set.new(other_detection_pairs.flatten)

			detection_pairs = map do |plugin_id, vulnerability|
				vulnerability.detections.map do |detection|
					{ plugin_id => detection }
				end
			end

			self_detections = Set.new(detection_pairs.flatten)

			detections = Set.new([other_detections, self_detections]).flatten

			t0 = Time.now

			detections.each do |detection_entry|
				in_self = self_detections.include? detection_entry
				in_other = other_detections.include? detection_entry

				detection = detection_entry.values.first

				if in_self && in_other
					detection.status = :present
				elsif !in_self && in_other
					detection.status = :removed
				elsif in_self && !in_other
					detection.status = :added
				else
					detection.status = true
				end
			end

			$stderr.puts "Detection status setting took #{Time.now - t0} seconds"

			added_plugin_ids = self_plugin_ids - other_plugin_ids
			deleted_plugin_ids = other_plugin_ids - self_plugin_ids
			all_plugin_ids = other_plugin_ids + added_plugin_ids

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
					detection_entry.keys.first == vulnerability.plugin_id
				end.map do |detection_entry|
					detection_entry.values.first
				end

				vulnerability.detections = plugin_detections.map do |detection|
					detection.dup
				end

				vulnerability
			end

			all_vulnerabilities
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

			first_row = true

			open(filename, 'rb') do |io|
				io.advise(:willneed)
				io.advise(:noreuse)
				io.advise(:sequential)

				FastCSV.raw_parse(io) do |row|
					if first_row
						first_row = false
						next
					end

					row_nessus_data = row[0..3] + row[7..-1]
					row_detection_data = row[4..6]

					plugin_id = row[0]

					unless !!dump_data[plugin_id]
						dump_data[plugin_id] = Vulnerability.new(*row_nessus_data)
					end

					row_detection = Detection.new(*row_detection_data)

					dump_data[plugin_id].add_detection(row_detection)
				end
			end

			dump_data
		end
	end
end

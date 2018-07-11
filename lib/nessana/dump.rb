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
			mitigated_vulnerabilities = other.select do |plugin_id, _v|
				!self[plugin_id]
			end.map do |plugin_id, vulnerability|
				vulnerability
			end

			additional_vulnerabilities = select do |plugin_id, _v|
				!other[plugin_id]
			end.map do |plugin_id, vulnerability|
				vulnerability
			end

			mitigated_detections = other.map do |plugin_id, other_vulnerability|
				# If we didn't already have an entry, all of the prior
				# detections have been mitigated.
				if !self[plugin_id]
					{ vulnerability: other_vulnerability, detections: other_vulnerability.detections }
				else
					current_vulnerability = self[plugin_id]
					change_in_detections = other_vulnerability.detections - current_vulnerability.detections
					{ vulnerability: other_vulnerability, detections: change_in_detections }
				end
			end

			additional_detections = map do |plugin_id, vulnerability|
				# If we didn't already have an entry in the prior dump, all of
				# our detections are new.
				if !other[plugin_id]
					{ vulnerability: vulnerability, detections: vulnerability.detections }
				else
					prior_vulnerability = other[plugin_id]
					change_in_detections = vulnerability.detections - prior_vulnerability.detections
					{ vulnerability: vulnerability, detections: change_in_detections }
				end
			end

			{
				:mitigated_vulnerabilities => mitigated_vulnerabilities,
				:new_vulnerabilities => additional_vulnerabilities,
				:fixed_detections => mitigated_detections,
				:new_detections => additional_detections
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

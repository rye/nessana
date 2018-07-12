require 'optparse'
require 'pp'
require 'ruby-prof'
require 'ruby-prof-flamegraph'

require 'nessana/executor/execution_configuration'
require 'nessana/filter'
require 'nessana/dump'

module Nessana
	module Executor
		def self.print_usage!
			puts @parser
		end

		def self.execute!(argv = ARGV)
			parse!(*argv)

			RubyProf.start if !!@configuration['performance']

			unless @configuration['old_filename']
				$stderr.puts 'No old dump filename given; will assume no prior knowledge.'
			end

			unless @configuration['new_filename']
				puts 'No new dump filename given; cannot do anything.'
				return
			end

			# TODO don't be silent

			filters = @configuration['filters'].map do |filter_hash|
				Filter.new(filter_hash)
			end

			old_dump = @configuration['old_filename'] ? Dump.new(@configuration['old_filename'], filters) : Dump.new
			new_dump = Dump.new(@configuration['new_filename'], filters)

			# diff = new_dump.old_old_dump

			# puts "The following vulnerabilities are NEW:"

			# diff[:added_vulnerabilities].each do |new_v|
			# 	puts new_v
			# 	puts "=" * 80
			# end

			# puts "\n" * 4

			# puts "The following detections are NEW:"

			# diff[:added_detections].each do |new_d|
			# 	vulnerability = new_d[:vulnerability]
			# 	detections = new_d[:detections].to_a

			# 	puts vulnerability.short_description
			# 	resulting_string = detections.map do |detection|
			# 		"+ #{detection.to_s}"
			# 	end.join("\n")
			# 	puts resulting_string
			# end

			# puts "\n" * 4

			# puts "The following detections were FIXED:"

			# diff[:removed_detections].each do |fixed|
			# 	vulnerability = fixed[:vulnerability]
			# 	detections = fixed[:detections].to_a

			# 	puts vulnerability.short_description
			# 	resulting_string = detections.map do |detection|
			# 		"- #{detection.to_s}"
			# 	end.join("\n")
			# 	puts resulting_string
			# end

			# puts "\n" * 4

			# puts "The following vulnerabilities were FIXED completely!"

			# diff[:removed_vulnerabilities].each do |fixed|
			# 	puts fixed.title_line
			# end

			diff = new_dump - old_dump

			diff.sort do |vulnerability_a, vulnerability_b|
				vulnerability_a[:plugin_id].to_i <=> vulnerability_b[:plugin_id].to_i
			end.sort do |vulnerability_a, vulnerability_b|
				vulnerability_a[:cvss].to_f <=> vulnerability_b[:cvss].to_f
			end.each do |v|
				puts "#{v}

DISCOVERIES"
				v.detections.sort do |detection_a, detection_b|
					detection_a[:port] <=> detection_b[:port]
				end.sort do |detection_a, detection_b|
					detection_a[:host] <=> detection_b[:host]
				end.each do |detection|
					if detection[:status] && detection[:status] != true
						puts detection.to_s
					end
				end
				puts "\n" * 2
			end

			if !!@configuration['performance']
				result = RubyProf.stop
				printer = RubyProf::FlameGraphPrinter.new(result)
				io = open(@configuration['performance'], 'wb')
				printer.print(io, {})
			end

			# Detections: print top line and synopsis for
			# Resolved detections: just print out in - form
			# Additional detections: print out + form

			# TODO check asana to see what needs to get created
			# TODO ask to create tasks
			# TODO automatically create tasks
		end

		def self.parse(*argv)
			configuration = ExecutionConfiguration.new

			option_parser = OptionParser.new do |parser|
				configuration.add_parser_hooks(parser)

				if argv.count == 0
					puts parser
					exit 1
				end

				parser.parse(*argv)
			end

			remaining_arguments = option_parser.order!(argv)

			case remaining_arguments.count
			when 2
				configuration['old_filename'] = remaining_arguments[0]
				configuration['new_filename'] = remaining_arguments[1]
			when 1
				configuration['old_filename'] = nil
				configuration['new_filename'] = remaining_arguments[0]
			end

			configuration.read_configuration_file!

			configuration
		end

		protected

		def self.parse!(*argv)
			@configuration = parse(*argv)
		end

	end
end

require 'pp'
require 'optparse'

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

			diff = new_dump - old_dump

			puts "The following vulnerabilities were FIXED:"

			diff[:fixed_v].each do |fixed|
				puts fixed
				puts "=" * 80
			end

			puts "The following vulnerabilities are NEW:"

			diff[:new_v].each do |new_v|
				puts new_v
				puts "=" * 80
			end

			# If mitigation, just print top line and synopsis.

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

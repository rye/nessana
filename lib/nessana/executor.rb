require 'optparse'
require 'pp'

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

			filters = @configuration['filters'].map do |filter_hash|
				Filter.new(filter_hash)
			end

			old_dump = @configuration['old_filename'] ? Dump.read(@configuration['old_filename'], filters) : Dump.new
			new_dump = Dump.read(@configuration['new_filename'], filters)

			diff = new_dump - old_dump

			diff.sort do |vulnerability_a, vulnerability_b|
				vulnerability_a.plugin_id.to_i <=> vulnerability_b.plugin_id.to_i
			end.sort do |vulnerability_a, vulnerability_b|
				vulnerability_a.cvss.to_f <=> vulnerability_b.cvss.to_f
			end.each do |v|
				puts "#{v}

DISCOVERIES"
				v.detections.sort_by(&:port).sort_by(&:host).each do |detection|
					if detection.status && detection.status != true
						puts detection.to_s
					end
				end
				puts "\n" * 2
			end
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

require 'pp'
require 'optparse'

require 'nessana/executor/execution_configuration'
require 'nessana/dump'

module Nessana
	module Executor
		def self.print_usage!
			puts @parser
		end

		def self.execute!(argv = ARGV)
			parse!(argv)

			unless @configuration['dump_filename']
				puts 'No dump filename given; not doing anything.'
				return
			end


			dump = Dump.new(@configuration['dump_filename'])
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

			option_parser.order! do |leftover_argument|
				configuration['dump_filename'] = leftover_argument if
					!configuration['dump_filename'] && File.readable?(leftover_argument)
			end

			configuration
		end

		protected

		def self.parse!(*argv)
			@configuration = parse(*argv)
		end

	end
end

require 'nessana/executor/execution_configuration'
require 'optparse'

module Nessana
	module Executor
		def self.print_usage!
			puts @parser
		end

		def self.execute!(*argv)
			parse!(*argv)

			unless @configuration[:dump_filename]
				puts 'No dump filename given; not doing anything.'
				exit 0
			end

			raise 'dump_filename nil!' unless !@configuration[:dump_filename].nil?
			raise 'cache_filename nil!' unless !@configuration[:cache_filename].nil?

			dump = Dump.from_file(@configuration[:dump_filename])
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

			configuration[:dump_filename] = argv.shift

			configuration
		end

		protected

		def self.parse!(*argv)
			@configuration = parse(*argv)
		end

	end
end

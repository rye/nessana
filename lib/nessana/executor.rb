require 'nessana/version'
require 'optparse'

module Nessana
	module Executor
		class ExecutionConfiguration
			attr_accessor :from_dump, :to_dump
			attr_accessor :verbosity

			def initialize
				verbosity = :info
			end

			def add_parser_hooks(parser)
				parser.banner = "Usage: #{ARGV[0]} [options]"
				parser.separator ""
				parser.separator "Execution Options"

				add_from_dump_option(parser)
				add_to_dump_option(parser)
				add_verbosity_option(parser)

				parser.separator ""
				parser.separator "General Options"
				add_usage_option(parser)
				add_verbosity_option(parser)

				parser.on_tail("-h", "--help", "Show this message") do
					puts parser
					exit
				end

				parser.on_tail("--version", "Show version") do
					puts VERSION
					exit
				end
			end

			protected

			def add_from_dump_option(parser)
				parser.on('-f', '--from FILENAME', "The filename to load as the original dump.")
			end

			def add_to_dump_option(parser)
				parser.on('-t', '--to FILENAME', "The filename to load as the new dump.")
			end

			def add_usage_option(parser)
				parser.on('-h', '--help', "Print usage summary.") do
					puts parser
					exit 0
				end
			end

			def add_verbosity_option(parser)
				parser.on('-v', '--verbosity VERBOSITY', "The level of verbosity to use.")
			end
		end

		def self.print_usage!
			puts @parser
		end

		def self.execute!(*argv)
			configuration = parse!(*argv)
		end

		protected

		def self.parse!(*argv)
			@configuration = ExecutionConfiguration.new
			@parser = OptionParser.new do |parser|
				@configuration.add_parser_hooks(parser)

				if argv.count == 0
					puts parser
					exit 1
				end

				parser.parse(*argv)
			end
			@configuration
		end
	end
end

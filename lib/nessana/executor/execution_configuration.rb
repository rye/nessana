require 'mime-types'

require 'nessana/version'

module Nessana::Executor
	class ExecutionConfiguration < ::Hash
		def initialize
			self['verbosity'] = 'info'
			self['config'] = 'config.yml'
			self['dump_filename'] = nil
		end

		# FIXME too many lines
		def add_parser_hooks(parser)
			parser.banner = "Usage: #{$PROGRAM_NAME} [options] <filename.csv>"
			parser.separator ''
			parser.separator 'Execution Options'

			add_config_option(parser)

			parser.separator ''
			parser.separator 'General Options'
			add_usage_option(parser)
			add_verbosity_option(parser)

			parser.on_tail('-h', '--help', 'Show this message') do
				puts parser
				exit
			end

			parser.on_tail('--version', 'Show version') do
				puts Nessana::VERSION
				exit
			end
		end

		# TODO deep merge?
		def read_configuration_file!
			merge!(read_configuration_file(self['config']))
		end

		protected

		def add_config_option(parser)
			parser.on('-c', '--config CONFIG', "Load configuration from CONFIG (default: #{self['config']})") do |config|
				self['config'] = config
			end
		end

		def add_usage_option(parser)
			parser.on('-h', '--help', 'Print usage summary.') do
				puts parser
				exit 0
			end
		end

		def add_verbosity_option(parser)
			parser.on('-v', '--verbosity VERBOSITY', "The level of verbosity to use. (default: #{self['verbosity']})")
		end

		def infer_mime_type(filename)
			MIME::Types.type_for(filename).first.content_type
		end

		# FIXME too many lines
		def read_configuration_file(filename)
			raise ArgumentError, 'Must pass a valid filename' if filename.nil?

			mime_type = infer_mime_type(filename)
			parsed = nil

			io = open(filename, 'rb')

			begin
				data = io.read

				case mime_type
				when /ya?ml/
					require 'yaml'
					parsed = YAML.load(data)
				when /json/
					require 'json'
					parsed = JSON.parse(data)
				end
			ensure
				io.close unless io.closed?
			end

			parsed.to_h
		end
	end
end

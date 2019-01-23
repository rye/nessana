require 'optparse'
require 'pp'
require 'tty-spinner'

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
				warn 'No old dump filename given; assuming you want this.'
			end

			unless @configuration['new_filename']
				puts 'No new dump filename given; cannot do anything.'
				return 1
			end

			filters = @configuration['filters'].map do |filter_hash|
				Filter.new(filter_hash)
			end

			spinner_options = {
				success_mark: "\u2713".encode('utf-8'),
				format: :dots_3
			}

			old_dump = nil

			if @configuration['old_filename']
				spinner = TTY::Spinner.new("[:spinner] Loading #{@configuration['old_filename']}...", **spinner_options)
				spinner.auto_spin

				old_dump = Dump.read(@configuration['old_filename'], filters)

				spinner.success('done!')
			else
				old_dump = Dump.new
			end

			spinner = TTY::Spinner.new("[:spinner] Loading #{@configuration['old_filename']}...", **spinner_options)
			spinner.auto_spin

			new_dump = Dump.read(@configuration['new_filename'], filters)

			spinner.success('done!')

			spinner = TTY::Spinner.new('[:spinner] Comparing dumps...', **spinner_options)
			spinner.auto_spin

			diff = new_dump - old_dump

			spinner.success('done!')

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

			0
		end

		def self.parse(*argv)
			configuration = ExecutionConfiguration.new

			option_parser = OptionParser.new do |parser|
				configuration.add_parser_hooks(parser)

				if argv.count == 0
					puts parser
					return 1
				end
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

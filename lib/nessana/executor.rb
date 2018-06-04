module Nessana
	module Executor
		def self.print_usage!
			puts 'Usage:'
		end

		def self.execute!(*argv)
			unless argv.count > 1
				print_usage!
				exit 1
			end
		end
	end
end

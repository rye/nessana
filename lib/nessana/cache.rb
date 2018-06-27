require 'sdbm'

module Nessana
	class Cache
		attr_reader :filename

		def initialize(filename)
			@filename = filename
			load_file!
		end

		def load_file!
			@db = load_file(@filename)
		end

		protected

		def load_file(filename)
			SDBM.open(filename)
		end
	end
end

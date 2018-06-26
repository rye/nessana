require 'nessana/vulnerability_list'

module Nessana
	class Dump < Array
		attr_reader :filename

		def initialize(filename)
			@filename = filename
			super(VulnerabilityList.from_csv(filename))
		end
	end
end

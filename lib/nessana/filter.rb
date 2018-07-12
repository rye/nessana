require 'ostruct'

require 'nessana/vulnerability'

module Nessana
	class Filter < Hash
		def initialize(hash)
			super

			fixed_hash = hash.map do |key, value|
				[key.to_sym, value]
			end.to_h

			merge!(fixed_hash)
		end

		def applies_to?(vulnerability)
			each do |key, value|
				case value
				when Regexp
					return true if vulnerability[key.to_sym] =~ value
				else
					return true if vulnerability[key.to_sym] == value
				end
			end

			false
		end
	end
end

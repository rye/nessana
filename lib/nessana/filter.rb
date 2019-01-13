require 'ostruct'

require 'nessana/vulnerability'

module Nessana
	class Filter < ::Hash
		def initialize(hash)
			super

			fixed_hash = hash.map do |key, value|
				[key.to_sym, value]
			end.to_h

			merge!(fixed_hash)
		end

		def applies_to?(vulnerability)
			each do |key, value|
				method = key.to_sym

				return false unless vulnerability.respond_to?(method)

				case value
				when Regexp
					return true if vulnerability.send(method).to_s =~ value
				else
					return true if vulnerability.send(method).to_s == value
				end
			end

			false
		end
	end
end

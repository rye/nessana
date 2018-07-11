module Nessana
	class Detection < Hash
		def initialize(host, protocol, port)
			self[:host], self[:protocol], self[:port] = host, protocol, port
		end

		def to_s
			"#{self[:host]}:#{self[:port]}/#{self[:protocol]}"
		end
	end
end

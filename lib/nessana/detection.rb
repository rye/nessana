module Nessana
	class Detection < Hash
		def initialize(host, protocol, port)
			self[:host], self[:protocol], self[:port] = host, protocol, port
		end
	end
end

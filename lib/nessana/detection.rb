module Nessana
	class Detection < Hash
		def initialize(host, protocol, port, status = nil)
			self[:host], self[:protocol], self[:port] = host, protocol, port
			self[:status] = status
		end

		def to_s
			"#{self[:status] ? status_prefix : ''}#{self[:host]}:#{self[:port]}/#{self[:protocol]}"
		end

		protected

		def status_prefix
			case self[:status]
			when :added
				'+ '
			when :removed
				'- '
			when :present
				'  '
			else
				'? '
			end
		end
	end
end

module Nessana
	class Detection < Hash
		attr_reader :status

		def initialize(host, protocol, port, status = nil)
			self[:host], self[:protocol], self[:port] = host, protocol, port
			@status = status
		end

		def to_s
			"#{@status ? status_prefix : ''}#{self[:host]}:#{self[:port]}/#{self[:protocol]}"
		end

		protected

		def status_prefix
			case @status
			when :added
				'+ '
			when :removed
				'- '
			else
				'? '
			end
		end
	end
end

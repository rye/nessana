module Nessana
	class Detection
		attr_reader :host, :protocol, :port
		attr_accessor :status

		def initialize(host, protocol, port, status = nil)
			@host, @protocol, @port = host, protocol, port
			@status = status
		end

		def to_s
			"#{@status ? status_prefix : ''}#{@host}:#{@port}/#{@protocol}"
		end

		protected

		def status_prefix
			case @status
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

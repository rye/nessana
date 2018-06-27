require 'csv'
require 'nessana/vulnerability_list'
require 'nessana/vulnerability'

module Nessana
	class Dump
		attr_reader :filename
		attr_reader :list

		def initialize(filename)
			@filename = filename
			read_csv!
		end

		# TODO implement
		def to_dbm
		end

		def read_csv!
			@list = read_csv(filename)
		end

		protected

		def read_csv(filename)
			rows = CSV.read(filename)

			vulnerabilities = rows[1..-1].map do |row|
				Vulnerability.new(*row)
			end

			VulnerabilityList.new(vulnerabilities)
		end
	end
end

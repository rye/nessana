require 'rspec'
require 'rspec/expectations'

require 'simplecov'
SimpleCov.start

RSpec.configure do |config|
end

RSpec::Matchers.define :be_requirable do
	match do |file|
		begin
			require file
		rescue LoadError
			return false
		end

		return true
	end
end

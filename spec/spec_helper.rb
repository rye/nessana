require 'simplecov'
SimpleCov.start

require 'coveralls'
Coveralls.wear!

require 'rspec'
require 'rspec/expectations'

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

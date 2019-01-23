require 'simplecov'
SimpleCov.start

if ENV['CI']
	require 'codecov'
	SimpleCov.formatter = SimpleCov::Formatter::Codecov
end

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

RSpec.configure do |rspec|
	rspec.around(:example) do |example|
		begin
			example.run
		rescue SystemExit => e
			fail "Got SystemExit: #{e.status}."
		end
	end
end

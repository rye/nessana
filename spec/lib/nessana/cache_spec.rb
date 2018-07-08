describe 'nessana/cache' do
	it { is_expected.to be_requirable }
end

require 'nessana/cache'

describe Nessana do
	describe '::Cache' do
		subject { Nessana::Cache }

		it { is_expected.to be_a(Class)}
	end
end

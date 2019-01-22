describe 'nessana/dump' do
	it { is_expected.to be_requirable }
end

require 'nessana/dump'

describe Nessana::Dump do
	it 'inherits from Hash' do
		expect(subject.class.ancestors).to include(Hash)
	end
end

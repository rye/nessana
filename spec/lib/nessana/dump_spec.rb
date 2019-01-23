describe 'nessana/dump' do
	it { is_expected.to be_requirable }
end

require 'nessana/dump'

describe Nessana::Dump do
	it 'inherits from Hash' do
		expect(subject.class.ancestors).to include(Hash)
	end

	describe '.read' do
		it 'reads from a file' do
			allow(File).to receive(:open)
			expect(File).to receive(:open).with('test file', 'rb')

			Nessana::Dump.read('test file')
		end
	end
end

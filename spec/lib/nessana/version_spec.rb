describe 'nessana/version' do
	it { is_expected.to be_requirable }
end

require 'nessana/version'

describe Nessana do
	subject { Nessana }

	it 'has a VERSION constant' do
		expect(subject.constants)
			.to include(:VERSION)
	end
end

describe Nessana::VERSION do
	subject { Nessana::VERSION }

	it 'is valid according to rubygems rules' do
		require 'rubygems/version'

		expect(Gem::Version.correct?(subject))
			.to eq(true)
	end
end

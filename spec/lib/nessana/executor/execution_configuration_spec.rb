describe 'nessana/executor/execution_configuration' do
	it { is_expected.to be_requirable }
end

require 'nessana/executor/execution_configuration'

describe Nessana::Executor do
	it 'has an ExecutionConfiguration constant' do
		expect(subject.constants).to include(:ExecutionConfiguration)
	end
end

describe Nessana::Executor::ExecutionConfiguration do
	it { is_expected.to be_a(Hash) }

	describe '#read_configuration!' do
		it 'calls #merge!' do
			allow(subject).to receive(:merge!)
			expect(subject).to receive(:merge!)
			subject.send(:read_configuration!)
		end
	end
end

describe 'nessana/executor' do
	it 'can be required' do
		expect { require subject }.not_to raise_exception
	end
end

require 'nessana/executor'

describe Nessana do
	it 'has an Executor constant, which is a module' do
		expect(subject.constants).to include(:Executor)
		expect(subject::Executor).to be_a(Module)
	end

	describe Nessana::Executor do
		it 'responds to execute!' do
			expect(subject).to respond_to(:execute!)
		end

		describe '.execute!' do
			before do
				allow(STDOUT).to receive(:write)
				allow(STDERR).to receive(:write)
			end

			context 'taking no command-line arguments' do
				let(:arguments) { [] }

				it 'produces usage message' do
					allow(Nessana::Executor).to receive(:exit)
					expect { subject.send(:execute!, *arguments) }.to(output(/Usage:/).to_stdout)
				end

				it 'exits with status 1' do
					allow(Nessana::Executor).to receive(:exit)
					expect(Nessana::Executor).to receive(:exit).with(1)

					subject.send(:execute!, *arguments)
				end
			end
		end
	end
end

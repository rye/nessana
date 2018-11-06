describe 'nessana/executor' do
	it { is_expected.to be_requirable }
end

require 'nessana/executor'

describe Nessana do
	it 'has an Executor constant, which is a module' do
		expect(subject.constants).to include(:Executor)
		expect(subject::Executor).to be_a(Module)
	end

	describe '::Executor' do
		subject { Nessana::Executor }

		it 'responds to execute!' do
			expect(subject).to respond_to(:execute!)
		end

		describe :'.execute!' do
			before do
				allow(subject).to receive(:exit)
				allow(STDOUT).to receive(:write)
				allow(STDERR).to receive(:write)
			end

			context 'taking no command-line arguments' do
				let(:arguments) { [] }

				it 'produces usage message' do
					expect { subject.send(:execute!, arguments) }.to(output(/Usage:/).to_stdout)
				end

				it 'exits with status 1' do
					expect(subject).to receive(:exit).with(1)

					subject.send(:execute!, arguments)
				end
			end

			context '--help' do
				let(:arguments) { ['--help'] }

				it 'produces usage message' do
					expect { subject.send(:execute!, arguments) }.to(output(/Usage:/).to_stdout)
				end

				it 'exits with status 0' do
					expect(subject).to receive(:exit).with(0)

					subject.send(:execute!, arguments)
				end
			end
		end
	end
end

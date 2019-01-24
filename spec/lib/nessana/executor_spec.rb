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
				allow(subject).to receive(:warn)
				allow(STDOUT).to receive(:write)
			end

			context 'with a non-ExecutionConfiguration configuration' do
				it 'returns the result from .parse' do
					allow(subject).to receive(:parse) { 2 }
					expect(subject.send(:execute!)).to eq(2)
				end
			end

			context 'with a configuration with __stop__ set' do
				it 'returns the value of ExecutionConfiguration' do
					allow(subject).to receive(:parse) do
						configuration = Nessana::Executor::ExecutionConfiguration.new
						configuration['__stop__'] = true
						configuration['__exit-code__'] = 7
						configuration
					end

					expect(subject.send(:execute!)).to eq(7)
				end
			end

			context 'with a configuration with old_filename not present' do
				it 'warns' do
					allow(subject).to receive(:parse) do
						configuration = Nessana::Executor::ExecutionConfiguration.new
						configuration['old_filename'] = nil
						configuration
					end

					expect(subject).to receive(:warn)
					expect { subject.send(:execute!) }.not_to raise_error
				end
			end

			context 'with a configuration with new_filename not present' do
				it 'warns' do
					allow(subject).to receive(:parse) do
						configuration = Nessana::Executor::ExecutionConfiguration.new
						configuration['new_filename'] = nil
						configuration
					end

					expect(subject).to receive(:warn)
					expect { subject.send(:execute!) }.not_to raise_error
					expect(subject.send(:execute!)).to eq(1)
				end
			end

			context 'taking no command-line arguments' do
				let(:arguments) { [] }

				it 'produces usage message' do
					expect do
						subject.send(:execute!, arguments)
					end.to(output(/Usage:/).to_stdout)
				end

				it 'returns 1' do
					expect(subject.send(:execute!, arguments)).to eq(1)
				end
			end

			[['--help'], ['-h']].each do |argv|
				context "taking #{argv.join(' ')}" do
					it 'produces usage message' do
						expect do
							subject.send(:execute!, argv)
						end.to(output(/Usage:/).to_stdout)
					end

					it 'returns 0' do
						expect(subject.send(:execute!, argv)).to eq(0)
					end
				end
			end

			[['--version'], ['-V']].each do |argv|
				context "taking #{argv.join(' ')}" do
					it 'prints the version of Nessana' do
						expect do
							subject.send(:execute!, argv)
						end.to(output(Regexp.new(Nessana::VERSION)).to_stdout)
					end

					it 'returns 0' do
						expect(subject.send(:execute!, argv)).to eq(0)
					end
				end
			end
		end
	end
end

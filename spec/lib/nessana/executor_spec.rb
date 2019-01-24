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

			context 'if .parse returns non-ExecutionConfiguration' do
				it 'returns the result from .parse' do
					allow(subject).to receive(:parse) { 2 }
					expect(subject.send(:execute!)).to eq(2)
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

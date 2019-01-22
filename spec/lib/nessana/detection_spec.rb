describe 'nessana/detection' do
	it { is_expected.to be_requirable }
end

require 'nessana/detection'

describe Nessana::Detection do
	describe '#to_s' do
		expectation_map = {
			:added => /^\+\ /,
			:removed => /^\-\ /,
			:present => /^\ \ /,
			:random => /^\?\ /,
			nil => /^\w+/
		}

		expectation_map.each do |status, expectation|
			context "on a detection with status #{status.inspect}" do
				subject do
					s = Nessana::Detection.allocate
					s.instance_variable_set(:@host, 'test.local')
					s.instance_variable_set(:@port, 12345)
					s.instance_variable_set(:@protocol, 'udp')
					s.instance_variable_set(:@status, status)
					s
				end

				it "prints a line matching #{expectation.inspect}" do
					expect(subject.to_s).to match(expectation)
				end
			end
		end
	end

	it 'is properly uniqable' do
		expect(([Nessana::Detection.new('localhost', 'tcp', 23)] * 2).uniq.count).to eq(1)
	end
end

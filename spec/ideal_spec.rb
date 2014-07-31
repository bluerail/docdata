require 'spec_helper'

describe Docdata::Ideal do
	it "returns a hash of at least 5 banks" do
		VCR.use_cassette("retrieve-bank-list") do
		  expect(Docdata::Ideal.banks).to be_kind_of(Array)
		  expect(Docdata::Ideal.banks.count).to be > 5
		end
	end

	it "each bank has a name and a code" do
		VCR.use_cassette("retrieve-bank-list") do
			bank_1 = Docdata::Ideal.banks.first
			expect(bank_1).to be_kind_of(Docdata::Bank)
		  expect(bank_1.id).to match /[0-9]{4}/
		  expect(bank_1.name).to match /[a-z]{3,}/i
		end
	end
end
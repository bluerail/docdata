require 'spec_helper'

describe Docdata do
  before(:each) do
  	Docdata.test_mode = true
  end

  it "returns correct version number" do
  	expect(Docdata.version).to eq(Docdata::VERSION)
  end

  context "settings" do
	  it "is in test mode by default" do
	  	expect(Docdata.test_mode).to eq(true)
	  end
	 
	  # it "should have the correct default values" do
	  #   expect(Docdata.test_mode).to be_truthy
	  #   expect(Docdata.username).to be_nil
	  #   expect(Docdata.password).to be_nil
	  # end

	  it "is able to update and set settings" do
	    Docdata.test_mode = false
	    Docdata.username = "abcd"
	    Docdata.password = "321zyx12"

	    expect(Docdata.test_mode).to be_falsey
	    expect(Docdata.username).to match "abcd"
	    expect(Docdata.password).to match "321zyx12"
	  end
	end

	context "SOAP configuration" do

    it "should have the proper test URL" do
      expect(Docdata.test_mode).to eq(true)
      expect(Docdata.url).to eq("https://test.docdatapayments.com/ps/services/paymentservice/1_1?wsdl")
    end

    it "should return a response" do
      VCR.use_cassette("wsdl-init") do
        expect(Docdata.client.class.to_s).to eq("Savon::Client")
      end
    end

    it "has methods to create, cancel, start, etc." do
      VCR.use_cassette("wsdl-client-methods") do
        expect(Docdata.client.operations).to match_array([:create, :cancel, :start, :refund, :status, :capture, :status_extended])
      end
    end
	end
end

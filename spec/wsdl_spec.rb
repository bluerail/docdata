require 'spec_helper'

describe Docdata::WSDL do
  before(:each) do
    @wsdl = Docdata::WSDL.new
    @config = Docdata::Config
    @config.wsdl = "https://test.docdatapayments.com/ps/services/paymentservice/1_1?wsdl"
    @wsdl.url = @config.wsdl
  end

  describe "#client" do
    it "should return a response" do
      VCR.use_cassette("wsdl-init") do
        expect(@wsdl.client.class.to_s).to eq("Savon::Client")
      end
    end

    it "has a service name" do
      VCR.use_cassette("wsdl-service-name") do
        expect(@wsdl.client.service_name).to eq("paymentService")
      end
    end

    it "has methods to create, cancel, start, etc." do
      VCR.use_cassette("wsdl-client-methods") do
        expect(@wsdl.client.operations).to match_array([:create, :cancel, :start, :refund, :status, :capture, :status_extended])
      end
    end
  end

end

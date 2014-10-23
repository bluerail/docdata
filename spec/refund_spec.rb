require 'spec_helper'

describe Docdata::Refund do

  context "validation" do
    it "has validation" do
      refund = Docdata::Refund.new
      expect(refund).not_to be_valid
    end

    it "validates amount" do
      refund = Docdata::Refund.new
      expect(refund).not_to be_valid
      expect(refund.errors.full_messages).to eq(["amount is not present", "amount is not a number", "currency is not present", "currency is not valid", "payment is not present"])
    end
  end

  context "valid refund" do
    before(:each) do
      Docdata.set_credentials_from_environment
      Docdata::Config.test_mode = true
      VCR.use_cassette("find-payment-by-key") do
        @payment = Docdata::Payment.find("2BAFAEB26EF760458B9343DEA4950D91")
        # puts @payment.inspect
      end
    end

    it "has a currency" do
      expect(@payment.currency).to be_present
      expect(@payment.currency).to eq("EUR")
    end

    it "performs refund" do
      VCR.use_cassette("refund-amount") do
        expect(@payment.refund(100)).to eq(true)
      end
    end

    it "performs refund with description" do
      VCR.use_cassette("refund-amount-with-description") do
        expect(@payment.refund(100, "user wanted to cancel...")).to eq(true)
      end
    end

  end

  context "successfull response" do
    before(:each) do
      file = "#{File.dirname(__FILE__)}/xml/refund_success.xml"
      @xml = open(file)
      @response = Docdata::Response.parse(:refund, @xml)
    end


    it "is successfull" do
      expect(@response).to be_success
    end

    it "has xml attribute with raw data" do
      expect(@response.xml).to be_present
    end
  end

  context "invalid amount response" do
    before(:each) do
      file = "#{File.dirname(__FILE__)}/xml/refund_invalid_amount.xml"
      @xml = open(file)
    end
    
    it "raises error" do
      expect { Docdata::Response.parse(:refund, @xml) }.to raise_error(DocdataError, "Invalid amount.")
    end
  end

  context "invalid amount response" do
    before(:each) do
      file = "#{File.dirname(__FILE__)}/xml/refund_no_amount_captured.xml"
      @xml = open(file)
    end
    
    it "raises error" do
      expect { Docdata::Response.parse(:refund, @xml) }.to raise_error(DocdataError, "No amount captured available to refund.")
    end
  end

end

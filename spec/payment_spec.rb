require 'spec_helper'

describe Docdata::Payment do
  before(:each) do
    @payment = Docdata::Payment.new
    @payment.amount = 500
    @payment.currency = "EUR"
  end

  describe "validations" do
    it "validates amount" do
      expect(@payment).to be_valid
      @payment.amount = nil
      expect(@payment).not_to be_valid
      expect(@payment.errors.count).to eq(2)
    end

    it "validates amount with message" do
      @payment.amount = nil
      expect(@payment).not_to be_valid
      expect(@payment.errors.full_messages).to eq(["amount is not present", "amount is not a number"])
    end

    it "validates precense and format of currency" do
      @payment.currency = nil
      expect(@payment).not_to be_valid
      expect(@payment.errors.full_messages).to include("currency is not valid")
    end
  end

  describe "#create" do
    it "communicates with the SOAP Api" do
      VCR.use_cassette("payments-create") do
        response = @payment.create
        expect(response.message).to eq("ok")
      end
    end

  end

  describe "#new" do
    
    it "returns a Payment object" do
      VCR.use_cassette("new-payment-object") do
        expect(@payment).to be_kind_of(Docdata::Payment)
      end
    end

    xit "returns error if not authenticated" do
      puts @payment.inspect
      expect(@payment).to eq("HOI")
    end

    xit "is unvalid" do
      expect(@payment).not_to be_valid
    end

    # it "returns an error if no price is specified" do
    #   result = @payment
    #   expect(@payment).to be_kind_of(Docdata::Payment)
    # end

  end


end

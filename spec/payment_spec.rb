require 'spec_helper'

describe Docdata::Payment do
  before(:each) do
    @shopper = Docdata::Shopper.create_valid_shopper
    @payment = Docdata::Payment.new
    @payment.amount = 500
    @payment.profile_id = "1234556"
    @payment.currency = "EUR"
    @payment.shopper = @shopper
  end

  describe "initialisation" do

    it "ititializes a new object through a hash" do
      payment = Docdata::Payment.new(amount: 500)
      expect(payment.amount).to eq(500)
    end
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

    it "has a shopper" do
      expect(@payment.shopper).to be_kind_of(Docdata::Shopper)
      expect(@payment.shopper.first_name).to eq("John")
    end
  end

  describe "#create" do

    it "raises error when credentials are wrong" do
      VCR.use_cassette("payments-xml-create-without-credentials") do
        expect { @payment.create }.to raise_error(DocdataError, "Login failed.")
      end
    end


    it "raises error when blank xml is sent" do
      Docdata.set_credentials_from_environment
      VCR.use_cassette("payments-successful-create") do
        response = @payment.create
        expect(response).to match /[A-Z0-9]{32}/
        # expect { @payment.create }.to raise_error(Savon::SOAPFault, "(S:Server) Not a number: ?")
      end
    end


  end

  describe "#new" do
    
    it "returns a Payment object" do
      # VCR.use_cassette("new-payment-object") do
        expect(@payment).to be_kind_of(Docdata::Payment)
      # end
    end

    xit "returns error if not authenticated" do
      # puts @payment.inspect
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

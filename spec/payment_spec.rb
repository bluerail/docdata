require 'spec_helper'

describe Docdata::Payment do
  before(:each) do
    @shopper = Docdata::Shopper.create_valid_shopper
    @payment = Docdata::Payment.new
    @payment.amount = 500
    @payment.profile = ENV["DOCDATA_PAYMENT_PROFILE"]
    @payment.order_reference = rand(500)
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
        expect(response).to be_kind_of(Docdata::Response)
        expect(response).to be_success
        expect(response.key).to match /[A-Z0-9]{32}/
        expect(@payment.key).to be_present
        expect(@payment.key).to eq(response.key)
        # expect { @payment.create }.to raise_error(Savon::SOAPFault, "(S:Server) Not a number: ?")
      end
    end

    it "has a redirect_url" do
      Docdata.set_credentials_from_environment
      VCR.use_cassette("payments-successful-create") do
        @payment.create
        # puts @payment.redirect_url
        expect(@payment.redirect_url).to include("https://test.docdatapayments.com/ps/menu?command=show_payment_cluster")

      end
    end

    it "redirect directly to the bank if bank_id is given" do
      Docdata.set_credentials_from_environment
      @payment.bank_id = "0031" # ABN AMRO
      VCR.use_cassette("payments-successful-create") do
        @payment.create
        puts @payment.redirect_url
        expect(@payment.redirect_url).to include("&default_act=true&ideal_issuer_id=0031&default_pm=IDEAL")
      end      
    end

    # it "has a different redirect_url for production mode" do
    #   Docdata.set_credentials_from_environment
    #   Docdata.test_mode = false
    #   VCR.use_cassette("payments-create-production-mode") do
    #     @payment.create
    #     puts @payment.redirect_url
    #     expect(@payment.redirect_url).to include("https://secure.docdatapayments.com/ps/menu?command=show_payment_cluster")
    #   end
    # end

  end

  describe "#new" do
    it "returns a Payment object" do
      expect(@payment).to be_kind_of(Docdata::Payment)
    end

  end
end

require 'spec_helper'

describe Docdata::Payment do
  before(:each) do
    Docdata::Config.test_mode = true
    @shopper = Docdata::Shopper.create_valid_shopper
    @payment = Docdata::Payment.new
    @payment.amount          = 500
    @payment.profile         = ENV["DOCDATA_PAYMENT_PROFILE"]
    @payment.order_reference = rand(500) + Time.now.to_i
    @payment.currency        = "EUR"
    @payment.description     = "Description of my order"
    @payment.shopper         = @shopper
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
      # puts @payment.xml
      Docdata::Config.password = "1234"
      VCR.use_cassette("payments-xml-create-without-credentials") do
        expect { @payment.create }.to raise_error(DocdataError, "Login failed.")
      end
    end

    it "raises error when password is blank" do
      Docdata::Config.password = ""
      VCR.use_cassette("payments-xml-create-without-password") do
        expect { @payment.create }.to raise_error(DocdataError, /The value '' of attribute 'password' on element '_1:merchant' is not valid with respect to its type/)
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

    it "has a payment" do
      Docdata.set_credentials_from_environment
      VCR.use_cassette("payments-successful-create") do
        @response = @payment.create
      end
      expect(@response.payment).to be_kind_of(Docdata::Payment)
    end

    it "replaces & for 'and'" do
      @payment.description = "Pete & Friends"
      expect(@payment.cleaned_up_description) == "Pete and Friends"
      expect(@payment.create_xml).to include("Pete and Friends")
    end

    it "has a `url` property" do
      Docdata.set_credentials_from_environment
      VCR.use_cassette("payments-successful-create") do
        @response = @payment.create
      end
      # puts @payment.redirect_url
      # puts @payment.inspect
      # puts @response.payment.inspect
      # puts @response.url
      expect(@response.url).to be_present
    end

    it "redirect directly to the bank if bank_id && default_act is given" do
      Docdata.set_credentials_from_environment
      @payment.bank_id = "0031" # ABN AMRO
      @payment.default_act = true
      VCR.use_cassette("payments-successful-create") do
        @payment.create
        # puts @payment.redirect_url
        expect(@payment.redirect_url).to include("&default_act=yes&ideal_issuer_id=0031&default_pm=IDEAL")
      end      
    end

  end

  describe "#find" do
    it "returns a Payment object if correct key is given" do
      Docdata.set_credentials_from_environment
      VCR.use_cassette("payments-successful-create") do
        @payment.create
      end
      expect(@payment.key).to be_present
      VCR.use_cassette("perform-valid-status-call") do
        @new_payment = Docdata::Payment.find(@payment.key)
      end
      expect(@new_payment).to be_kind_of(Docdata::Payment)
    end

    it "returns a pid" do
      file = "#{File.dirname(__FILE__)}/xml/status-paid-ideal.xml"
      @xml = open(file)
      @response = Docdata::Response.parse(:status, @xml)

      @payment = @response.payment
      expect(@response.is_paid?).to eq(true)
      # expect(@payment).to be_kind_of(Docdata::Payment)
      expect(@response.pid).to match /[0-9]{10}/

    end

    it "raises error if order is not found" do
      VCR.use_cassette("perform-invalid-status-call") do
        Docdata.set_credentials_from_environment
        expect { @new_payment = Docdata::Payment.find("THISWILLPRODUC3AN3RROR") }.
          to raise_error(DocdataError, "Order could not be found with the given key.")
      end
    end
  end

  describe "#status" do
    it "returns 'success'" do
      Docdata.set_credentials_from_environment
      VCR.use_cassette("payments-successful-create") do
        @payment.create
      end
      VCR.use_cassette("perform-valid-status-call") do
        @new_payment = Docdata::Payment.find(@payment.key)
      end
      VCR.use_cassette("status-call") do
        @response = @new_payment.status
      end
      expect(@response).to be_kind_of(Docdata::Response)      
      expect(@response).to be_success

    end
  end

  it "returns paid == false by default" do
      Docdata.set_credentials_from_environment
      VCR.use_cassette("payments-successful-create") do
        @payment.create
      end
      VCR.use_cassette("perform-valid-status-call") do
        @new_payment = Docdata::Payment.find(@payment.key)
      end
      VCR.use_cassette("status-call") do
        @response = @new_payment.status
      end
      expect(@response).not_to be_paid   
  end

  describe "#new" do
    it "returns a Payment object" do
      expect(@payment).to be_kind_of(Docdata::Payment)
    end
  end

  describe "#cancel" do
    before(:each) do
      Docdata::Config.test_mode = true
      Docdata.set_credentials_from_environment
      VCR.use_cassette("payments-successful-create") do
        @payment.create
      end
    end

    it "returns a response object" do
      VCR.use_cassette("payments-successful-cancel") do
        @response = @payment.cancel
      end
      expect(@response).to be(true)
    end

    it "has attribute 'canceled' to true" do
      VCR.use_cassette("payments-successful-cancel") do
        @response = @payment.cancel
      end
      expect(@payment.canceled).to eq(true)
    end

    it "combines find and cancel in one call" do

        VCR.use_cassette("payments-find-and-cancel") do
        @payment = Docdata::Payment.cancel(@payment.key)
      end
    end
  end
end

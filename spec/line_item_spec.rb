require 'spec_helper'

describe Docdata::LineItem do
  before(:each) do
    @shopper = Docdata::Shopper.create_valid_shopper
    @payment = Docdata::Payment.new
    @payment.amount = 500
    @payment.profile = ENV["DOCDATA_PAYMENT_PROFILE"]
    @payment.order_reference = rand(500)
    @payment.currency = "EUR"
    @payment.shopper = @shopper
  end

  describe "#new" do
    it "validates attributes" do
      line_item = Docdata::LineItem.new
      expect(line_item).not_to be_valid
      expect(line_item.errors.full_messages).to include("name is not present")
      expect(line_item.errors.full_messages).to include("code is not present")
      expect(line_item.errors.full_messages).to include("quantity is not present")
      expect(line_item.errors.full_messages).to include("price_per_unit is not present")
      expect(line_item.errors.full_messages).to include("description is not present")
      expect(line_item.errors.full_messages).to include("unit_of_measure is not present")
    end
  end

  it "raises error when payment is created and LineItems are not valid" do
    line_item = Docdata::LineItem.new
    @payment.line_items << line_item
    VCR.use_cassette("payments-create-with-invalid-line-items") do
      expect { @payment.create }.to raise_error(DocdataError, "One of your line_items is invalid. Error messages: name is not present, quantity is not present, quantity is not a number, price_per_unit is not present, price_per_unit is not a number, description is not present, unit_of_measure is not present")      
    end
  end

  describe "successfull payments" do

    before(:each) do
      @line_item = Docdata::LineItem.new
      @line_item.name            = "Green eggs and Ham"
      @line_item.code            = "GEH123"
      @line_item.quantity        = 1
      @line_item.price_per_unit  = 1299
      @line_item.description     = "Book by dr. Seuss"
      @line_item.unit_of_measure = "book"
    end

    it "makes create request with line items" do
      
      @payment.line_items << @line_item
      VCR.use_cassette("payments-create-with-valid-line-items") do
        result = @payment.create
        expect(result).to be_success
      end
    end

  end
end

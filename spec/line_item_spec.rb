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
      expxect(line_item).not_to be_valid
    end
  end
end

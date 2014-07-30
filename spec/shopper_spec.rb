require 'spec_helper'

describe Docdata::Shopper do
  before(:each) do
    @shopper = Docdata::Shopper.new
    @shopper.first_name = "John"
    @shopper.last_name = "Doe"
  end

  it "has a name" do
    expect(@shopper.first_name).to eq("John")
  end

  it "has a full name" do
    expect(@shopper.name).to eq("John Doe")
  end

  it "belongs to a payment" do
    @payment = Docdata::Payment.new
    @payment.amount = 500
    @payment.currency = "EUR"
    @payment.shopper = @shopper
    expect(@payment.shopper).to be_kind_of(Docdata::Shopper)
    expect(@payment.shopper.first_name).to eq("John")
  end

end
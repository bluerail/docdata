require 'spec_helper'

describe Docdata::Shopper do
  before(:each) do
    @shopper = Docdata::Shopper.new
    @shopper.first_name = "John"
    @shopper.last_name = "Doe"
  end

  context "validations" do
    it "validates attributes" do
      shopper = Docdata::Shopper.new
      expect(shopper).not_to be_valid
      expect(shopper.errors.count).to eq(1)
      expect(shopper.errors.full_messages).to include("id is not present")
    end

    it "creates a valid shopper" do
      shopper = Docdata::Shopper.create_valid_shopper
      expect(shopper).to be_valid
    end

    it "sets up proper defaults" do
      shopper = Docdata::Shopper.new
      expect(shopper.first_name).to eq("First Name")
      expect(shopper.last_name).to eq("Last Name")
      expect(shopper.street).to eq("Main Street")
      expect(shopper.house_number).to eq("123")
    end

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
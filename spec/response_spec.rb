require 'spec_helper'

describe Docdata::Response do
  context ":status, new unpaid payment" do
    before(:each) do
      file = "#{File.dirname(__FILE__)}/xml/status-new.xml"
      @xml = open(file)
      @response = Docdata::Response.parse(:status, @xml)
    end

    it "is not paid" do
      expect(@response).to be_success
    end
  end

end

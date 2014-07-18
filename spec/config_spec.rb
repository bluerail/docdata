require 'spec_helper'

describe Docdata::Config do
  before(:each) do
    @config = Docdata::Config
    @config.test_mode = true
    @config.username = "abcdefg"
    @config.password = "321zyx12"
  end

  describe "#reset!" do
    it "should reset the values" do
      @config.reset!
      expect(@config.test_mode).to be_truthy
      expect(@config.username).to be_nil
      expect(@config.password).to be_nil
    end
  end

  describe "#update!" do
    it "should update" do
      @config.reset!
      @config.test_mode = false
      @config.username = "abcd"
      @config.password = "321zyx12"
      @config.update!

      config = Docdata::Config
      expect(config.test_mode).to be_falsey
      expect(config.username).to match "abcd"
      expect(config.password).to match "321zyx12"
    end
  end
end

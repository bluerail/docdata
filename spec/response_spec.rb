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

    it "has xml attribute with raw data" do
      expect(@response.xml).to be_present
    end
  end

  describe "response with multiple payment nodes (canceled first, paid later)" do
    before(:each) do
      file = "#{File.dirname(__FILE__)}/xml/status-paid-ideal-multiple.xml"
      @xml = open(file)
      @response = Docdata::Response.parse(:status, @xml)
    end    

    it "returs a response object" do
      expect(@response).to be_kind_of(Docdata::Response)
    end

    it "is paid" do
      expect(@response.paid).to eq(true)
    end
  end


  describe "response with multiple payment nodes (paid first, canceled later)" do
    before(:each) do
      file = "#{File.dirname(__FILE__)}/xml/status-paid-multiple-and-canceled.xml"
      @xml = open(file)
      @response = Docdata::Response.parse(:status, @xml)
    end    

    it "returs a response object" do
      expect(@response).to be_kind_of(Docdata::Response)
    end

    it "is of method IDEAL" do
      expect(@response.payment_method).to eq("IDEAL")
    end

    it "is paid?" do
      expect(@response.paid?).to eq(true)
    end

    it "is paid" do
      # puts "IS PAID: #{total_registered} && #{total_captured}"
      expect(@response.total_registered).to eq(2600)
      expect(@response.total_captured).to eq(2600)      
      expect(@response.paid).to eq(true)
    end
  end


  describe "response with multiple payment nodes (paid first, canceled later)" do
    before(:each) do
      file = "#{File.dirname(__FILE__)}/xml/status-paid-canceled-ideal-multiple.xml"
      @xml = open(file)
      @response = Docdata::Response.parse(:status, @xml)
    end    

    it "returs a response object" do
      expect(@response).to be_kind_of(Docdata::Response)
    end

    it "is paid" do
      expect(@response.paid).to eq(true)
    end
  end


  describe "different payment methods" do
    context ":status, paid iDeal" do
      before(:each) do
        file = "#{File.dirname(__FILE__)}/xml/status-paid-ideal.xml"
        @xml = open(file)
        @response = Docdata::Response.parse(:status, @xml)
      end

      it "has 'total_registered' method" do
        # puts @response.inspect
        expect(@response.total_registered).to eq(500)
      end

      it "returns 0 for empty values" do
        expect(@response.total_shopper_pending).to eq(0)
      end

      it "returns amount" do
        expect(@response.amount).to eq(500)
      end

      it "returns payment_method" do
        expect(@response.payment_method).to eq("IDEAL")
      end

      it "is paid" do
        expect(@response).to be_success
        expect(@response).to be_paid
      end



      it "has currency EUR" do
        expect(@response.xml).to be_present
        expect(@response.currency).to eq("EUR")
      end

      it "is NOT canceled" do
        expect(@response).to be_success
        expect(@response).not_to be_canceled
      end

    end

    context ":status, canceled iDeal" do
      before(:each) do
        file = "#{File.dirname(__FILE__)}/xml/status-canceled-ideal.xml"
        @xml = open(file)
        @response = Docdata::Response.parse(:status, @xml)
      end

      it "has 'total_registered' method" do
        expect(@response.total_registered).to eq(500)
      end

      it "returns 0 for empty values" do
        expect(@response.total_shopper_pending).to eq(0)
      end

      it "returns amount" do
        # puts "xml: #{@response.xml}"
        expect(@response.amount).to eq(500)
      end

      it "returns payment_method" do
        expect(@response.payment_method).to eq("IDEAL")
      end

      it "is NOT paid" do
        expect(@response).to be_success
        expect(@response).not_to be_paid
      end

      it "is canceled" do
        expect(@response).to be_success
        expect(@response).to be_canceled
      end    

    end

    context ":status, paid creditcard" do
      before(:each) do
        file = "#{File.dirname(__FILE__)}/xml/status-paid-creditcard.xml"
        @xml = open(file)
        @response = Docdata::Response.parse(:status, @xml)
      end

      it "has 'total_registered' method" do
        expect(@response.total_registered).to eq(500)
      end

      it "returns amount" do
        expect(@response.amount).to eq(500)
      end

      it "returns payment_method" do
        expect(@response.payment_method).to eq("MASTERCARD")
      end

      it "is paid" do
        expect(@response).to be_success
        expect(@response).to be_paid
      end

      it "is NOT canceled" do
        expect(@response).to be_success
        expect(@response).not_to be_canceled
      end
    end

    context ":status, canceled creditcard" do
      before(:each) do
        file = "#{File.dirname(__FILE__)}/xml/status-canceled-creditcard.xml"
        @xml = open(file)
        @response = Docdata::Response.parse(:status, @xml)
      end

      it "returns amount" do
        expect(@response.amount).to eq(500)
      end

      it "is NOT paid" do
        expect(@response).to be_success
        expect(@response).not_to be_paid
      end

      it "is canceled" do
        expect(@response).to be_success
        expect(@response).to be_canceled
      end    

    end  

    context ":status, paid sofort" do
      before(:each) do
        file = "#{File.dirname(__FILE__)}/xml/status-paid-sofort.xml"
        @xml = open(file)
        @response = Docdata::Response.parse(:status, @xml)
      end

      it "has 'total_registered' method" do
        expect(@response.total_registered).to eq(500)
      end

      it "returns amount" do
        expect(@response.amount).to eq(500)
      end

      it "returns payment_method" do
        expect(@response.payment_method).to eq("SOFORT_UEBERWEISUNG")
      end

      it "is paid" do
        expect(@response).to be_success
        expect(@response).to be_paid
      end

      it "is NOT canceled" do
        expect(@response).to be_success
        expect(@response).not_to be_canceled
      end
    end

    # context ":status, canceled sofort" do
    #   before(:each) do
    #     file = "#{File.dirname(__FILE__)}/xml/status-canceled-sofort.xml"
    #     @xml = open(file)
    #     @response = Docdata::Response.parse(:status, @xml)
    #   end

    #   it "returns amount" do
    #     expect(@response.amount).to eq(500)
    #   end

    #   it "is NOT paid" do
    #     expect(@response).to be_success
    #     expect(@response).not_to be_paid
    #   end

    #   it "is canceled" do
    #     expect(@response).to be_success
    #     expect(@response).to be_canceled
    #   end    

    # end  

  end
end
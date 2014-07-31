module Docdata

  # Creates a validator
  class PaymentValidator
      require 'veto'
      include Veto.validator

      validates :amount, presence: true, integer: true
      validates :profile_id, presence: true, integer: true
      validates :currency, presence: true, format: /[A-Z]{3}/
  end



  #
  # Object representing a "WSDL" object with attributes provided by Docdata
  #
  # @example
  #   Payment.new({
  #     :amount => 2500,
  #     :currency => "EUR",
  #     :order_reference => "TJ123"
  #     :shopper => @shopper
  #   })
  class Payment

    # @return [Array] Errors
    attr_accessor :errors
    # @return [Integer] The total price in cents
    attr_accessor :amount
    @@amount = "?"
    # @return [String] ISO currency code (USD, EUR, GBP, etc.)
    attr_accessor :currency
    # @return [String] A unique order reference
    attr_accessor :order_reference
    # @return [Integer] The DocData profile ID
    attr_accessor :profile_id
    # @return [Shopper] A shopper object (instance of Docdata::Shopper)
    attr_accessor :shopper
    # @retun [String] The Docdata Payment key returned after #create
    attr_accessor :key




    #
    # Initializer to transform a +Hash+ into an Payment object
    #
    # @param [Hash] args
    def initialize(args=nil)
      return if args.nil?
      args.each do |k,v|
        instance_variable_set("@#{k}", v) unless v.nil?
      end
    end

    def valid?
      validator = PaymentValidator.new
      validator.valid?(self)
    end

    def create
      xml_file = "#{File.dirname(__FILE__)}/xml/create.xml.erb"
      template = File.read(xml_file)      
      namespace = OpenStruct.new(payment: self, shopper: shopper)
      xml = ERB.new(template).result(namespace.instance_eval { binding })
      response = Docdata.client.call(:create, xml: xml)
      return Docdata::Response.parse(:create, response)
    end

    def start
      xml_file = "#{File.dirname(__FILE__)}/xml/start.xml.erb"
      template = File.read(xml_file)      
      namespace = OpenStruct.new(payment: self, shopper: shopper)
      xml = ERB.new(template).result(namespace.instance_eval { binding })
      response = Docdata.client.call(:create, xml: xml)
      return Docdata::Response.parse(:create, response)
    end    
  end
end

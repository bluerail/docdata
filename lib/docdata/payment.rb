module Docdata
  
  # Creates a validator
  class PaymentValidator
      require 'veto'
      include Veto.validator

      validates :amount, presence: true, integer: true
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
    # @return [String] ISO currency code (USD, EUR, GBP, etc.)
    attr_accessor :currency
    # @return [String] ISO country code (us, nl, de, uk)
    attr_accessor :country_code
    # @return [String] A unique order reference
    attr_accessor :order_reference
    # @return [Integer] The DocData profile ID
    attr_accessor :profile_id
    # @return [Shopper] A shopper object (instance of Docdata::Shopper)
    attr_accessor :shopper



    #
    # Initializer to transform a +Hash+ into an Payment object
    #
    # @param [Hash] values
    def initialize(values=nil)
      return if values.nil?
    end

    def valid?
      validator = PaymentValidator.new
      validator.valid?(self)
    end

    def create
      puts "Shopper: #{shopper.inspect}"
      xml_file = "#{File.dirname(__FILE__)}/xml/create.xml.erb"
      template = File.read(xml_file)
      require 'ostruct'
      namespace = OpenStruct.new(payment: self, shopper: shopper)
      xml = ERB.new(template).result(namespace.instance_eval { binding })
      response = Docdata.client.call(:create, xml: xml)
      if response && response.body[:create_response] && response.body[:create_response][:create_error]
        raise DocdataError.new(response), response.body[:create_response][:create_error][:error]
      else
        return response.to_hash
      end
    end
  end
end

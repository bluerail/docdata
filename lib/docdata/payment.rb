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
  #   })
  class Payment

    # @return [Array] Errors
    attr_accessor :errors
    # @return [Integer] The total price in cents
    attr_accessor :amount
    # @return [String] ISO currency code (USD, EUR, GBP, etc.)
    attr_accessor :currency
    # @return [String] A unique order reference
    attr_accessor :order_reference

    #
    # Initializer to transform a +Hash+ into an Payment object
    #
    # @param [Hash] values
    def initialize(values=nil)
      # @config.wsdl = "https://test.docdatapayments.com/ps/services/paymentservice/1_1?wsdl"
      
      return if values.nil?
      # @client = Docdata::WSDL.client
      # # @client.call(:create, message: { username: "luke", password: "secret" })
      # @response = @client.call(:create) do |locals|
      #   locals.message username: "luke", password: "secret"
      #   locals.wsse_auth "luke", "secret", :digest
      # end
      # if values["url"].present?
      #   @url = values["url"].to_s
      # else
      #   @url = Docdata::Config.wsdl
      # end
    end

    def valid?
      validator = PaymentValidator.new
      validator.valid?(self)
    end

    def merchant
      {name: "Name", password: "Passw0rd"}
    end

    def create
      xml = File.read("#{File.dirname(__FILE__)}/xml/create.xml.erb")
      response = Docdata.client.call(:create, xml: xml)
      # :create_response=>{:
        # create_error=>{
          # :error=>"XML request does not match XSD. The data is: cvc-complex-type.2.4.b: The content of element 'ddp:createRequest' is not complete. One of '{\"http://www.docdatapayments.com/services/paymentservice/1_1/\":merchant}' is expected.."}, :@xmlns=>"http://www.docdatapayments.com/services/paymentservice/1_1/"}
          puts "========================================="
      puts response.body
      if response && response.body[:create_response] && response.body[:create_response][:create_error]
        raise DocdataError.new(response), response.body[:create_response][:create_error][:error]
      else
        return response.to_hash
      end
    end
  end
end

module Docdata


  #
  # Object representing a "response" with attributes provided by Docdata
  #
  # @example
  #   :create_success=>{
  #     :success=>"Operation successful.", 
  #     :key=>"A7B623A3A7DB5949316F82049450C3F3"
  #   }
  class Response

    # @return [String] Payment key for future correspondence about this transaction
    attr_accessor :key
    # @return [Boolean] 
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
      if response && response.body[:create_response] && response.body[:create_response][:create_error]
        raise DocdataError.new(response), response.body[:create_response][:create_error][:error]
      else
        return response.to_hash
      end
    end
  end
end

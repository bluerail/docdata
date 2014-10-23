module Docdata


  # Creates a validator
  class RefundValidator
    include Veto.validator
    validates :amount, presence: true, integer: true
    validates :currency, presence: true, format: /[A-Z]{3}/
    validates :payment, presence: true
  end


  #
  # Refund
  #
  # @example
  #   Refund.new({
  #     :amount => 2500,
  #     :currency => "EUR",
  #     :description => "Canceled order #123"
  #     :payment => @payment
  #   })
  # 

  # 
  class Refund
    attr_accessor :errors
    attr_accessor :amount
    attr_accessor :currency
    attr_accessor :payment
    attr_accessor :description
    @@amount = "?"

    #
    # Initializer to transform a +Hash+ into an Refund object
    #
    # @param [Hash] args
    def initialize(args=nil)
      @line_items = []
      return if args.nil?
      args.each do |k,v|
        instance_variable_set("@#{k}", v) unless v.nil?
      end
    end

    # @return [Boolean] true/false, depending if this instanciated object is valid
    def valid?
      validator = RefundValidator.new
      validator.valid?(self)
    end

    # 
    # This calls the 'refund' method of the SOAP API
    # It refunds (part of) the payment and returns a Docdata::Response object
    def perform_refund
      # make the SOAP API call
      response        = Docdata.client.call(:refund, xml: refund_xml)
      response_object = Docdata::Response.parse(:refund, response)
      if response_object.success?
        return true
      else
        return false
      end
    end

    # @return [String] the xml to send in the SOAP API
    def refund_xml
      xml_file        = "#{File.dirname(__FILE__)}/xml/refund.xml.erb"
      template        = File.read(xml_file)      
      namespace       = OpenStruct.new(refund: self, payment: self.payment)
      xml             = ERB.new(template).result(namespace.instance_eval { binding })
    end


  end

end

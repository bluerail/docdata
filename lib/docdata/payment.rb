module Docdata

  # Creates a validator
  class PaymentValidator
      require 'veto'
      include Veto.validator

      validates :amount, presence: true, integer: true
      validates :profile, presence: true
      validates :currency, presence: true, format: /[A-Z]{3}/
      validates :order_reference, presence: true
  end



  #
  # Object representing a "WSDL" object with attributes provided by Docdata
  #
  # @example
  #   Payment.new({
  #     :amount => 2500,
  #     :currency => "EUR",
  #     :order_reference => "TJ123"
  #     :profile => "MyProfile"
  #     :shopper => @shopper
  #   })
  class Payment

    # @return [Array] Errors
    attr_accessor :errors
    # @param [Integer] The total price in cents
    attr_accessor :amount
    @@amount = "?"
    # @param [String] ISO currency code (USD, EUR, GBP, etc.)
    attr_accessor :currency
    # @param [String] A unique order reference
    attr_accessor :order_reference
    # @param [String] The DocData payment profile (e.g. 'MyProfile')
    attr_accessor :profile
    # @param [Shopper] A shopper object (instance of Docdata::Shopper)
    attr_accessor :shopper
    # @param [String] (optional) in case you want to redirect the consumer
    # directly to the bank page (iDeal), you can set the bank id ('0031' for ABN AMRO for example.)
    attr_accessor :bank_id
    # @param [String] (optional) set a prefered payment method.
    # any of: [IDEAL, AMAX, VISA, etc.]
    attr_accessor :prefered_payment_method
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
      xml_file        = "#{File.dirname(__FILE__)}/xml/create.xml.erb"
      template        = File.read(xml_file)      
      namespace       = OpenStruct.new(payment: self, shopper: shopper)
      xml             = ERB.new(template).result(namespace.instance_eval { binding })
      response        = Docdata.client.call(:create, xml: xml)
      response_object = Docdata::Response.parse(:create, response)
      if response_object.success?
        self.key = response_object.key
      end
      return response_object
    end

    def start
      xml_file = "#{File.dirname(__FILE__)}/xml/start.xml.erb"
      template = File.read(xml_file)      
      namespace = OpenStruct.new(payment: self, shopper: shopper)
      xml = ERB.new(template).result(namespace.instance_eval { binding })
      response = Docdata.client.call(:start, xml: xml)
      return Docdata::Response.parse(:start, response)
    end    

    def redirect_url
      url = {}
      
      base_url = Docdata.return_url
      if Docdata.test_mode
        redirect_base_url = 'https://test.docdatapayments.com/ps/menu'
      else
        redirect_base_url = 'https://secure.docdatapayments.com/ps/menu'
      end
      url[:command]             = "show_payment_cluster"
      url[:payment_cluster_key] = key
      url[:merchant_name]       = Docdata.username
      url[:return_url_success]  = "#{base_url}/success?key=#{url[:payment_cluster_key]}"
      url[:return_url_pending]  = "#{base_url}/pending?key=#{url[:payment_cluster_key]}"
      url[:return_url_canceled] = "#{base_url}/canceled?key=#{url[:payment_cluster_key]}"
      url[:return_url_error]    = "#{base_url}/error?key=#{url[:payment_cluster_key]}"
      url[:locale]              = ''
      
      params = URI.encode_www_form(url)
      uri = "#{redirect_base_url}?#{params}"
    end
  end
end

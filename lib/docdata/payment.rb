module Docdata

  # Creates a validator
  class PaymentValidator
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
  # 
  # @return [Array] Errors
  # @param :amount [Integer] The total price in cents
  # @param :currency [String] ISO currency code (USD, EUR, GBP, etc.)
  # @param :order_reference [String] A unique order reference
  # @param :profile [String] The DocData payment profile (e.g. 'MyProfile')
  # @param :shopper [Docdata::Shopper] A shopper object (instance of Docdata::Shopper)
  # @param :bank_id [String] (optional) in case you want to redirect the consumer
  # directly to the bank page (iDeal), you can set the bank id ('0031' for ABN AMRO for example.)
  # @param :prefered_payment_method [String] (optional) set a prefered payment method.
  # any of: [IDEAL, AMAX, VISA, etc.]
  # @param :line_items [Array] (optional) Array of objects of type Docdata::LineItem
  # 
  class Payment
    attr_accessor :errors
    attr_accessor :amount
    @@amount = "?"
    attr_accessor :currency
    attr_accessor :order_reference
    attr_accessor :profile
    attr_accessor :shopper
    attr_accessor :bank_id
    attr_accessor :prefered_payment_method
    attr_accessor :line_items
    attr_accessor :key




    #
    # Initializer to transform a +Hash+ into an Payment object
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
      validator = PaymentValidator.new
      validator.valid?(self)
    end

    # 
    # This is the most importent method. It uses all the attributes
    # and performs a `create` action on Docdata Payments SOAP API. 
    # @return [Docdata::Response] response object with `key`, `message` and `success?` methods
    # 
    # 
    def create
      # if there are any line items, they should all be valid.
      validate_line_items

      # read the xml template
      xml_file        = "#{File.dirname(__FILE__)}/xml/create.xml.erb"
      template        = File.read(xml_file)      
      namespace       = OpenStruct.new(payment: self, shopper: shopper)
      xml             = ERB.new(template).result(namespace.instance_eval { binding })

      # make the SOAP API call
      response        = Docdata.client.call(:create, xml: xml)
      response_object = Docdata::Response.parse(:create, response)
      if response_object.success?
        self.key = response_object.key
      end
      return response_object
    end

    # @return [String] The URI where the consumer can be redirected to in order to pay
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
      url[:client_language]     = shopper.language_code
      if bank_id.present?
        url[:default_act]     = true
        url[:ideal_issuer_id] = bank_id
        url[:default_pm]      = "IDEAL"
      end
      params = URI.encode_www_form(url)
      uri = "#{redirect_base_url}?#{params}"
    end

    # In case there are any line_items, validate them all and
    # raise an error for the first invalid LineItem
    def validate_line_items
      if @line_items.any?
        for line_item in @line_items
          if line_item.valid?
            # do nothing, this line_item seems okay
          else
            raise DocdataError.new(line_item), line_item.error_message
          end
        end
      end
    end
  end
end

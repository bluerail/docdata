module Docdata

  # Creates a validator
  class PaymentValidator
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
  # 
  # @return [Array] Errors
  # @param :amount [Integer] The total price in cents
  # @param :currency [String] ISO currency code (USD, EUR, GBP, etc.)
  # @param :order_reference [String] A unique order reference
  # @param :profile [String] The DocData payment profile (e.g. 'MyProfile')
  # @param :description [String] Description for this payment
  # @param :receipt_text [String] A receipt text
  # @param :shopper [Docdata::Shopper] A shopper object (instance of Docdata::Shopper)
  # @param :bank_id [String] (optional) in case you want to redirect the consumer
  # directly to the bank page (iDeal), you can set the bank id ('0031' for ABN AMRO for example.)
  # @param :prefered_payment_method [String] (optional) set a prefered payment method.
  # any of: [IDEAL, AMAX, VISA, etc.]
  # @param :line_items [Array] (optional) Array of objects of type Docdata::LineItem
  # @param :default_act [Boolean] (optional) Should the redirect URL contain a default_act=true parameter?
  # 
  class Payment
    attr_accessor :errors
    attr_accessor :amount
    @@amount = "?"
    attr_accessor :description
    attr_accessor :receipt_text
    attr_accessor :currency
    attr_accessor :order_reference
    attr_accessor :profile
    attr_accessor :shopper
    attr_accessor :bank_id
    attr_accessor :prefered_payment_method
    attr_accessor :line_items
    attr_accessor :key
    attr_accessor :default_act
    attr_accessor :canceled


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
    def create
      # if there are any line items, they should all be valid.
      validate_line_items

      # make the SOAP API call
      response        = Docdata.client.call(:create, xml: create_xml)
      response_object = Docdata::Response.parse(:create, response)
      if response_object.success?
        self.key = response_object.key
      end

      # set `self` as the value of the `payment` attribute in the response object
      response_object.payment = self
      response_object.url     = redirect_url

      return response_object
    end

    # 
    # This calls the 'cancel' method of the SOAP API
    # It cancels the payment and returns a Docdata::Response object
    def cancel
      # make the SOAP API call
      response        = Docdata.client.call(:cancel, xml: cancel_xml)
      response_object = Docdata::Response.parse(:cancel, response)
      if response_object.success?
        self.key = response_object.key
      end

      # set `self` as the value of the `payment` attribute in the response object
      response_object.payment = self
      self.canceled = true
      return true
    end

    # This method makes it possible to find and cancel a payment with only the key
    # It combines 
    def self.cancel(api_key)
      p = self.find(api_key)
      p.cancel
    end

    # Initialize a Payment object with the key set
    def self.find(api_key)
      p = self.new(key: api_key)
      if p.status.success
        return p
      else
        raise DocdataError.new(p), p.status.message
      end
    end

    # 
    # This is one of the other native SOAP API methods.
    # @return [Docdata::Response]
    def status
      # read the xml template
      xml_file        = "#{File.dirname(__FILE__)}/xml/status.xml.erb"
      template        = File.read(xml_file)      
      namespace       = OpenStruct.new(payment: self)
      xml             = ERB.new(template).result(namespace.instance_eval { binding })

      # puts xml

      response        = Docdata.client.call(:status, xml: xml)
      response_object = Docdata::Response.parse(:status, response)

      return response_object # Docdata::Response
    end

    # @return [String] The URI where the consumer can be redirected to in order to pay
    def redirect_url
      url = {}
      
      base_url = Docdata::Config.return_url
      if Docdata::Config.test_mode
        redirect_base_url = 'https://test.docdatapayments.com/ps/menu'
      else
        redirect_base_url = 'https://secure.docdatapayments.com/ps/menu'
      end
      url[:command]             = "show_payment_cluster"
      url[:payment_cluster_key] = key
      url[:merchant_name]       = Docdata::Config.username
      # only include return URL if present
      if base_url.present?
        url[:return_url_success]  = "#{base_url}/success?key=#{url[:payment_cluster_key]}"
        url[:return_url_pending]  = "#{base_url}/pending?key=#{url[:payment_cluster_key]}"
        url[:return_url_canceled] = "#{base_url}/canceled?key=#{url[:payment_cluster_key]}"
        url[:return_url_error]    = "#{base_url}/error?key=#{url[:payment_cluster_key]}"
      end
      if shopper && shopper.language_code
        url[:client_language]      = shopper.language_code
      end
      if default_act
        url[:default_act]     = "yes"
      end
      if bank_id.present?
        url[:ideal_issuer_id] = bank_id
        url[:default_pm]      = "IDEAL"
      end
      params = URI.encode_www_form(url)
      uri = "#{redirect_base_url}?#{params}"
    end
    alias_method :url, :redirect_url


    private


    # @return [String] the xml to send in the SOAP API
    def create_xml
      xml_file        = "#{File.dirname(__FILE__)}/xml/create.xml.erb"
      template        = File.read(xml_file)      
      namespace       = OpenStruct.new(payment: self, shopper: shopper)
      xml             = ERB.new(template).result(namespace.instance_eval { binding })
    end


    # @return [String] the xml to send in the SOAP API
    def cancel_xml
      xml_file        = "#{File.dirname(__FILE__)}/xml/cancel.xml.erb"
      template        = File.read(xml_file)      
      namespace       = OpenStruct.new(payment: self)
      xml             = ERB.new(template).result(namespace.instance_eval { binding })
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

    # @return [Hash] list of VAT-rates and there respective totals
    def vat_rates
      rates = {}
      for item in @line_items
        rates["vat_#{item.vat_rate.to_s}"] ||= {}
        rates["vat_#{item.vat_rate.to_s}"][:rate] ||= item.vat_rate
        rates["vat_#{item.vat_rate.to_s}"][:total] ||= 0
        rates["vat_#{item.vat_rate.to_s}"][:total] += item.vat
      end
      return rates
    end

  end
end

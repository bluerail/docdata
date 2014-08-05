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
    # @return [Boolean] true/false, depending of the API response
    attr_accessor :success
    @@success = false
    alias_method :success?, :success
    


    # @return [String] Response message from DocData
    attr_accessor :message

    # @return [Hash] The parsed report node of the reponse-xml
    attr_accessor :report

    # @return [String] The raw XML returned by the API
    attr_accessor :xml


    #
    # Initializer to transform a +Hash+ into an Response object
    #
    # @param [Hash] args
    def initialize(args=nil)
      @report = {}
      return if args.nil?
      args.each do |k,v|
        instance_variable_set("@#{k}", v) unless v.nil?
      end
    end


    # 
    # Parses the returned response hash and turns it
    # into a new Docdata::Response object
    # 
    # @param [String] method_name (name of the method: create, start, cancel, etc.)
    # @param [Hash] response
    def self.parse(method_name, response)
      body, xml = self.response_body(response)      
      if body["#{method_name}_response".to_sym] && body["#{method_name}_response".to_sym]["#{method_name}_error".to_sym]
        raise DocdataError.new(response), body["#{method_name}_response".to_sym]["#{method_name}_error".to_sym][:error]
      else
        m = body["#{method_name}_response".to_sym]["#{method_name}_success".to_sym]
        r = self.new(key: m[:key], message: m[:success], success: true)
        if m[:report]
          r.report = m[:report]
          r.xml    = xml #save the raw xml
        end
        return r
      end
    end

    # @return [Hash] the body of the response. In the test environment, this uses
    # plain XML files, in normal use, it uses a `Savon::Response`
    def self.response_body(response)
      if response.is_a?(File)
        parser = Nori.new(:convert_tags_to => lambda { |tag| tag.snakecase.to_sym })
        xml = response.read 
        body = parser.parse(xml).first.last.first.last
      else
        body = response.body.to_hash
        xml = response.xml
      end
      return body, xml
    end

    methods = [:total_registered, :total_shopper_pending, :total_acquier_pending, :total_acquirer_approved, :total_captured, :total_refunded, :total_chargedback]
    methods.each do |method|
      define_method method do
        report[:approximate_totals][method].to_i
      end
    end

    # @return [String] the payment method of this transaction
    def payment_method
      if report[:payment]
        report[:payment][:payment_method]
      else
        nil
      end
    end

    # @return [String] the status string provided by the API. One of [AUTHORIZED, CANCELED]
    def payment_status
      report[:payment][:authorization][:status]
    end

    # @return [Boolean] true/false, depending wether this payment is considered paid.
    # @note Docdata doesn't explicitly say 'paid' or 'not paid', this is a little bit a gray area.
    # There are several approaches to determine if a payment is paid, some slow and safe, other quick and unreliable.
    # The reason for this is that some payment methods have a much longer processing time. For each payment method
    # a different 'paid'.
    # @note This method is never 100% reliable. If you need to finetune this, please implement your own method, using
    # the available data (total_captured, total_registered, etc.)
    def paid
      if payment_method
        case payment_method
        # ideal
        when "IDEAL"
          (total_registered == total_captured) && (capture_status == "CAPTURED")
        # creditcard
        when "MASTERCARD", "VISA", "AMEX"
          (total_registered == total_acquirer_approved)
        # fallback: if total_registered equals total_caputured,
        # we can assume that this order is paid. No 100% guarantee.
        else
          total_registered == total_captured
        end
      else
        false
      end
    end
    alias_method :paid?, :paid

    # @return [Boolean]
    def authorized
      payment_status == "AUTHORIZED"
    end
    alias_method :authorized?, :authorized

    # @return [Boolean]
    def canceled
      payment_status == "CANCELED" || capture_status == "CANCELED"
    end
    alias_method :canceled?, :canceled

    # @return [String] the status of the capture, if exists
    def capture_status
      report[:payment][:authorization][:capture][:status]
    end

    # @return [Integer] the caputred amount in cents
    def amount
      report[:payment][:authorization][:amount].to_i
    end
    
    # @return [String] the caputred amount in cents
    # @note TODO, this method is not implemented yet
    def currency
      # report[:payment][:authorization][:@exchanged_to]
    end


  end
end

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

    # @return [Boolean]
    attr_accessor :paid

    # @return [Integer] the captured amount in cents
    attr_accessor :amount
    
    # @return [String] the status of this response (capture response)
    attr_accessor :status

    # @return [String] Currency ("EUR", "GBP", "USD", etc.)
    attr_accessor :currency

    # @return [Docdata::Payment] object 
    attr_accessor :payment

    # @return [String] the return URL
    attr_accessor :url

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


    # [Integer] the amount to set, calculated from the multiple payment nodes
    def amount_to_set
      #  if (report && Response.payment_node(report) && Response.payment_node(report)[:authorization] && Response.payment_node(report)[:authorization][:amount].present?)
      if (report && Response.payment_node(report) && Response.payment_node(report)[:authorization] && Response.payment_node(report)[:authorization][:amount].present?)
        if canceled
          return Response.payment_node(report)[:authorization][:amount].to_i
        else
          return total_acquirer_pending + total_acquirer_approved
        end
      else
        return false
      end
    end

    # Set the attributes based on the API response
    def set_attributes
      self.paid     = is_paid?
      self.amount   = amount_to_set if amount_to_set
      self.status   = capture_status if capture_status
      self.currency = currency_to_set
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
        r.xml    = xml #save the raw xml
        # puts m[:report]
        if m[:report]
          r.report = m[:report]
        end
        r.set_attributes
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

    methods = [:total_registered, :total_shopper_pending, :total_acquirer_pending, :total_acquirer_approved, :total_captured, :total_refunded, :total_chargedback]
    methods.each do |method|
      define_method method do
        report[:approximate_totals][method].to_i
      end
    end

    # @return [String] the payment method of this transaction
    def payment_method
      begin
        if report && Response.payment_node(report).present? && Response.payment_node(report)[:payment_method].present?
          Response.payment_node(report)[:payment_method].to_s
        else
          nil
        end
      rescue
        nil
      end
    end


    # @return [String] the status string provided by the API. One of [AUTHORIZED, CANCELED]
    def payment_status
      if report && Response.payment_node(report) && Response.payment_node(report)[:authorization]
        Response.payment_node(report)[:authorization][:status]
      else
        nil
      end
    end

    # @return [String] the PID of the transaction
    def pid
      if report && Response.payment_node(report) && Response.payment_node(report)[:id]
        Response.payment_node(report)[:id]
      else
        nil
      end      
    end

    # @return [Boolean] true/false, depending wether this payment is considered paid.
    # @note Docdata doesn't explicitly say 'paid' or 'not paid', this is a little bit a gray area.
    # There are several approaches to determine if a payment is paid, some slow and safe, other quick and unreliable.
    # The reason for this is that some payment methods have a much longer processing time. For each payment method
    # a different 'paid'.
    # @note This method is never 100% reliable. If you need to finetune this, please implement your own method, using
    # the available data (total_captured, total_registered, etc.)
    ## from the Docs:
    ### Safe route: 
    # The safest route to check whether all payments were made is for the merchants
    # to refer to the “Total captured” amount to see whether this equals the “Total registered
    # amount”. While this may be the safest indicator, the downside is that it can sometimes take a
    # long time for acquirers or shoppers to actually have the money transferred and it can be
    # captured.
    ### Quick route: 
    # Another option is to see whether the sum of “total shopper pending”, “total
    # acquirer pending” and “total acquirer authorized” matches the “total registered sum”. This
    # implies that everyone responsible has indicated that they are going to make the payment and
    # that the merchant is trusting that everyone will indeed make this. While this route will be
    # faster, it does also have the risk that some payments will actually not have been made.
    ### Balanced route: 
    # Depending on the merchant's situation, it can be a good option to only refer
    # to certain totals. For instance, if the merchant only makes use of credit card payments it
    # could be a good route to only look at “Total acquirer approved”, since this will be rather safe
    # but quicker than looking at the captures.
    def is_paid?

      if payment_method
        case payment_method
        # ideal (dutch)
        when "IDEAL" 
          (total_registered == total_captured) ## && (capture_status == "CAPTURED")
        # creditcard
        when "MASTERCARD", "VISA", "AMEX"
          (total_registered == total_acquirer_approved)
        # sofort überweisung (german)
        when "SOFORT_UEBERWEISUNG"
          (total_registered == total_acquirer_approved)
        # podium giftcard (dutch)
        when "PODIUM_GIFTCARD"
          (total_registered == total_captured)
        # fallback: if total_registered equals total_caputured,
        # we can assume that this order is paid. No 100% guarantee.
        else
          total_registered == total_acquirer_approved
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
      (payment_status && payment_status == "CANCELED") || 
        (capture_status && capture_status == "CANCELED")
    end
    alias_method :canceled?, :canceled

    # @return [String] the status of the capture, if exists
    def capture_status
      if report && Response.payment_node(report) && Response.payment_node(report)[:authorization] && Response.payment_node(report)[:authorization][:capture]
        Response.payment_node(report)[:authorization][:capture][:status]
      else
        nil
      end
    end

    
    # @return [String] the currency if this transaction
    def currency_to_set
      if status_xml &&  status_xml.xpath("//amount").any?
        status_xml.xpath("//amount").first.attributes["currency"].value
      else
        nil
      end
    end

    # @return [Nokogiri::XML::Document] object
    def doc
      # remove returns and whitespaces between tags
      xml_string = xml.gsub("\n", "").gsub(/>\s+</, "><")
      # return Nokogiri::XML::Document
      @doc ||= Nokogiri.XML(xml_string)
    end

    # @return [Nokogiri::XML::Document] object, containing only the status section
    # @note This is a fix for Nokogiri's trouble finding xpath elements after 'xlmns' attribute in a node.
    def status_xml
      @status_xml ||= Nokogiri.XML(doc.xpath("//S:Body").first.children.first.children.first.to_xml)
    end

    private

    # Sometimes a single response has multiple payment nodes. When a payment fails first and 
    # succeeds later, for example. In that case, always use the newest (== highest id) node.
    # UPDATE (2/3/2015) this is not always the case: a payment can receive a 'canceled' payment 
    # later on with a higher ID, but the order is still paid.
    def self.payment_node(hash)
      if hash[:payment] && hash[:payment].is_a?(Hash)
        hash[:payment]
      elsif hash[:payment] && hash[:payment].is_a?(Array)
        # use the node with the highest ID, for it is the newest
        list = hash[:payment].sort_by { |k| k[:id] }
        return list.last
      else
        false
      end
    end

  end
end

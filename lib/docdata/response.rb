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
    
    # @return [Boolean] true/false, depending of the API response
    attr_accessor :paid
    @@paid = false
    alias_method :paid?, :paid


    # @return [String] Response message from DocData
    attr_accessor :message

    # @return [Hash] The parsed report node of the reponse-xml
    attr_accessor :report

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
      if response.is_a?(File)
        parser = Nori.new(:convert_tags_to => lambda { |tag| tag.snakecase.to_sym })
        xml = response.read 
        # puts xml
        puts parser.parse(xml)
        body = parser.parse(xml).first.last.first.last

      else
        body = response.body.to_hash
      end
      
      # puts body
      if body["#{method_name}_response".to_sym] && body["#{method_name}_response".to_sym]["#{method_name}_error".to_sym]
        raise DocdataError.new(response), body["#{method_name}_response".to_sym]["#{method_name}_error".to_sym][:error]
      else
        m = body["#{method_name}_response".to_sym]["#{method_name}_success".to_sym]
        r = self.new(key: m[:key], message: m[:success], success: true)
        if m[:report]
          r.report = m[:report]
        end
        return r
      end
    end
    
  end
end

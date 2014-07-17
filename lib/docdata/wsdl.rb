module Docdata
  #
  # Object representing a "WSDL" object with attributes provided by Docdata
  #
  # @example
  #   WSDL.new({
  #     :url => "http://example.org?wsdl"
  #   })
  class WSDL
    require 'savon'

    # @return [String] The URL of the WSDL file.
    attr_accessor :url

    #
    # Initializer to transform a +Hash+ into an WSDL object
    #
    # @param [Hash] values
    def initialize(values=nil)
      return if values.nil?
      if values["url"].present?
        @url = values["url"].to_s
      else
        @url = Docdata::Config.wsdl
      end
    end

    def client
      ::Savon.client(wsdl: @url)
    end

  end

end

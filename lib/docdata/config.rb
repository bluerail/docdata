#
# Configuration object for storing some parameters required for making transactions
#
module Docdata::Config
  class << self
    # @return [String] Your DocData username
    # @note The is a required parameter.
    attr_accessor :username
    # @return [String] Your DocData password
    attr_accessor :password
    # @return [String] URL to the WSDL
    attr_accessor :wsdl
    # @return [Boolean] Test mode switch
    attr_accessor :test_mode


    # Set's the default value's to nil and false
    # @return [Hash] configuration options
    def init!
      @defaults = {
        :@username => nil,
        :@password => nil,
        :@wsdl     => nil,
        :@test_mode => false
      }
    end

    # Resets the value's to there previous value (instance_variable)
    # @return [Hash] configuration options
    def reset!
      @defaults.each { |key, value| instance_variable_set(key, value) }
    end

    # Set's the new value's as instance variables
    # @return [Hash] configuration options
    def update!
      @defaults.each do |key, value|
        instance_variable_set(key, value) unless instance_variable_defined?(key)
      end
    end
  end
  init!
  reset!
end

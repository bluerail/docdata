#  Files
require 'rails'
require 'active_support/dependencies'
require 'active_support'
require "docdata/version"
require "docdata/docdata_error"
require "docdata/payment"
require 'savon'

include Savon
# 
# Docdata Module
# 
module Docdata
  API_VERSION = 1

  # @return [String] Your DocData username
  # @note The is a required parameter.
  mattr_accessor :username
  @@username = nil

  # @return [String] Your DocData password
  mattr_accessor :password
  @@password = nil

  # @return [Boolean] Test mode switch
  mattr_accessor :test_mode
  @@test_mode = true


  # returns the version number
  def self.version
    VERSION
  end 

  # sets up configuration
  def self.setup
    yield self
  end

  def self.url
    if test_mode
      "https://test.docdatapayments.com/ps/services/paymentservice/1_1?wsdl"
    else
      "https://www.docdatapayments.com/ps/services/paymentservice/1_1?wsdl"
    end
  end

  def self.client
    Savon.client(wsdl: url)
  end
end

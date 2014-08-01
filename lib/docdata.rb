# Libraries
require 'ostruct'
require 'rails'
require 'savon'
require 'active_support/dependencies'
require 'active_support'
require 'open-uri'
require 'nokogiri'
require 'veto'


#  Files
require "docdata/version"
require "docdata/docdata_error"
require "docdata/shopper"
require "docdata/payment"
require "docdata/line_item"
require "docdata/response"
require "docdata/ideal"
require "docdata/bank"

include Savon
include Veto.validator

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

  # @param [String] Set the url of your website where docdata can send messages to
  mattr_accessor :return_url
  @@return_url = nil

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

  # For testing purpose only: set the username and password
  # in environment variables to make the tests pass with your test
  # credentials.
  def self.set_credentials_from_environment
    self.password   = ENV["DOCDATA_PASSWORD"]
    self.username   = ENV["DOCDATA_USERNAME"]
    self.return_url = ENV["DOCDATA_RETURN_URL"]
  end

  def self.client
    Savon.client(wsdl: url)
  end

end

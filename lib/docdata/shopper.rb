module Docdata
  
  # Creates a validator
  class ShopperValidator
      require 'veto'
      include Veto.validator

      # validates :amount, presence: true, integer: true
      # validates :currency, presence: true, format: /[A-Z]{3}/
  end



  #
  # Object representing a "Shopper"
  #
  # @example
  #   Shopper.new({
  #     :amount => 2500,
  #     :currency => "EUR",
  #     :order_reference => "TJ123"
  #   })
  class Shopper

    # @return [Array] Errors
    attr_accessor :errors
    # @return [Integer] The shopper ID
    attr_accessor :id
    # @return [String] Shopper first name
    attr_accessor :first_name
    # @return [String] Shopper last name
    attr_accessor :last_name
    # @return [String] Shopper street address
    attr_accessor :street
    # @return [String] Shopper house number
    attr_accessor :house_number
    # @return [String] Shopper postal code
    attr_accessor :postal_code
    # @return [String] Shopper city
    attr_accessor :city
    # @return [String] Shopper email
    attr_accessor :email




    #
    # Initializer to transform a +Hash+ into an Shopper object
    #
    # @param [Hash] values
    def initialize(values=nil)
      return if values.nil?
    end

    def name
      "#{first_name} #{last_name}"
    end

    def valid?
      validator = ShopperValidator.new
      validator.valid?(self)
    end

  end
end

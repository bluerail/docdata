module Docdata
  
  # Creates a validator
  class ShopperValidator
      require 'veto'
      include Veto.validator

      # validates :amount, presence: true, integer: true
      # validates :currency, presence: true, format: /[A-Z]{3}/
      validates :id, presence: true
      validates :first_name, presence: true
      validates :last_name, presence: true
      validates :street, presence: true
      validates :house_number, presence: true
      validates :postal_code, presence: true
      validates :city, presence: true
      validates :email, presence: true
      validates :country_code, presence: true, format: /[A-Z]{2}/
      validates :language_code, presence: true, format: /[a-z]{2}/
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
    # @return [String] ISO country code (us, nl, de, uk)
    attr_accessor :country_code
    # @return [String] ISO language code (en, nl, de)
    attr_accessor :language_code




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

    # Returns true if this instanciated object is valid
    def valid?
      validator = ShopperValidator.new
      validator.valid?(self)
    end

    # This method will instanciate and return a new Shopper object
    # with all the required properties set. Mostly for testing purpose,
    # but maybe usefull in other scenarios as well.
    def self.create_valid_shopper
      shopper = self.new
      shopper.id            = "789"
      shopper.first_name    = "John"
      shopper.last_name     = "Doe"
      shopper.country_code  = "NL"
      shopper.language_code = "nl"
      shopper.email         = "test@example.org"
      shopper.street        = "Main street"
      shopper.house_number  = "123"
      shopper.postal_code   = "1122AB"
      shopper.city          = "Test City"
      return shopper
    end

  end
end

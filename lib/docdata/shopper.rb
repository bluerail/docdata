module Docdata
  
  # Creates a validator
  class ShopperValidator
    include Veto.validator
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
  #     :first_name => "Jack",
  #     :last_name => "Sixpack"
  #     :id => "MC123"
  #   })
  # @param format [String] The shopper ID
  # @param format [String] Shopper first name
  # @param format [String] Shopper last name
  # @param format [String] Gender ['M','F']
  # @param format [String] Shopper street address
  # @param format [String] Shopper house number
  # @param format [String] Shopper postal code
  # @param format [String] Shopper city
  # @param format [String] Shopper email
  # @param format [String] ISO country code (us, nl, de, uk)
  # @param format [String] ISO language code (en, nl, de)
  class Shopper

    # @return [Array] Errors
    attr_accessor :errors
    attr_accessor :id
    attr_accessor :first_name
    attr_accessor :last_name
    attr_accessor :gender
    attr_accessor :street
    attr_accessor :house_number
    attr_accessor :postal_code
    attr_accessor :city
    attr_accessor :email
    attr_accessor :country_code
    attr_accessor :language_code




    #
    # Initializer to transform a +Hash+ into an Shopper object
    #
    # @param [Hash] args
    def initialize(args=nil)
      self.set_default_values
      return if args.nil?
      args.each do |k,v|
        instance_variable_set("@#{k}", v) unless v.nil?
      end

    end

    def name
      "#{first_name} #{last_name}"
    end

    # Returns true if this instanciated object is valid
    def valid?
      validator = ShopperValidator.new
      validator.valid?(self)
    end

    
    def set_default_values
      @first_name    = "First Name"
      @last_name     = "Last Name"
      @street        = "Main Street"
      @house_number  = "123"
      @postal_code   = "2244"
      @city          = "City"
      @country_code  = "NL"
      @language_code = "nl"
      @gender        = "M"
      @email         = "random@example.com"
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

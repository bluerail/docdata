module Docdata
  

  # Creates a validator
  class LineItemValidator
      require 'veto'
      include Veto.validator

      
      # validates :currency, presence: true, format: /[A-Z]{3}/
      validates :name, presence: true
      validates :quantity, presence: true, integer: true
      validates :price_per_unit, presence: true, integer: true
      validates :description, presence: true
      validates :unit_of_measure, presence: true
  end


  #
  # Object representing a "LineItem"
  #
  # @example
  #   LineItem.new({
  #     :name => "Ham and Eggs by dr. Seuss",
  #     :quantity => 1,
  #     :unit_of_measure => "book",
  #     :description => "The famous childrens book",
  #     :image => "http://blogs.slj.com/afuse8production/files/2012/06/GreenEggsHam1.jpg",
  #     :price_per_unit => 1299
  #   })
  class LineItem

    # @return [Array] Errors
    attr_accessor :errors
    # @params [String]
    attr_accessor :name
    # @params [Integer]
    attr_accessor :quantity
    # @params [String] ('Books', 'Tickets')
    attr_accessor :unit_of_measure
    # @params [String] 
    attr_accessor :description
    # @params [String] (URI to image)
    attr_accessor :image
    # @params [Integer] (price in cents) 
    attr_accessor :price_per_unit

    #
    # Initializer to transform a +Hash+ into an LineItem object
    #
    # @param [Hash] args
    def initialize(args=nil)
      return if args.nil?
      args.each do |k,v|
        instance_variable_set("@#{k}", v) unless v.nil?
      end
    end

    # @return [Boolean] true/false, depending if this instanciated object is valid
    def valid?
      validator = LineItemValidator.new
      validator.valid?(self)
    end

    # @return [String] the string that contains all the errors for this line_item
    def error_message
      "One of your line_items is invalid. Error messages: #{errors.full_messages.join(', ')}"
    end
  end
end

module Docdata
  

  # Creates a validator
  class LineItemValidator
    include Veto.validator

    validates :name, presence: true
    validates :quantity, presence: true, integer: true
    validates :price_per_unit, presence: true, integer: true
    validates :description, presence: true
    validates :code, presence: true
  end


  #
  # Object representing a "LineItem"
  #
  # @example
  #   LineItem.new({
  #     :name => "Ham and Eggs by dr. Seuss",
  #     :code => "EAN312313235",
  #     :quantity => 1,
  #     :description => "The famous childrens book",
  #     :image => "http://blogs.slj.com/afuse8production/files/2012/06/GreenEggsHam1.jpg",
  #     :price_per_unit => 1299,
  #     :vat_rate => 17.5,
  #     :vat_included => true
  #   })
  #  @note Warning: do not use this part of the gem, for it will break. Be warned!
  class LineItem
    attr_accessor :errors
    attr_accessor :name
    attr_accessor :code
    attr_accessor :quantity
    attr_accessor :unit_of_measure
    attr_accessor :description
    attr_accessor :image
    attr_accessor :price_per_unit
    attr_accessor :vat_rate
    attr_accessor :vat_included

    #
    # Initializer to transform a +Hash+ into an LineItem object
    #
    # @param [Hash] args
    def initialize(args=nil)
      @unit_of_measure = "PCS"
      @vat_rate        = 0
      @vat_included    = true
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

    # @return [Integer] total price of this line item
    def total_price
      price_per_unit * quantity
    end

    def gross_amount
      if vat_included
        total_price
      else
        total_price + vat
      end
    end

    def nett_amount
      if vat_included
        total_price - vat
      else
        total_vat
      end
    end

    # @return [Integer] the total amount of VAT (in cents) that is applicable for this line item,
    # based on the vat_rate, quantity and price_per_unit
    def vat
      if vat_included
        ((gross_amount.to_f * "1.#{vat_rate.to_s.gsub('.','')}".to_f) - gross_amount) * -1
      else
        ((nett_amount.to_f * "1.#{vat_rate.to_s.gsub('.','')}".to_f) - nett_amount)
      end
    end
  end
end

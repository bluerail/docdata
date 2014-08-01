module Docdata
  
  #
  # Object representing a "Line item"
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
    attr_accessor :unit_of_mesaure
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
  end
end

module Docdata


  # Creates a validator
  class RefundValidator
    include Veto.validator
    validates :amount, presence: true, integer: true
    validates :currency, presence: true, format: /[A-Z]{3}/
    validates :payment, presence: true
  end


  #
  # Refund
  #
  # @example
  #   Refund.new({
  #     :amount => 2500,
  #     :currency => "EUR",
  #     :description => "Canceled order #123"
  #     :payment => @payment
  #   })
  # 

  # 
  class Refund
    attr_accessor :errors
    attr_accessor :amount
    attr_accessor :currency
    attr_accessor :payment
    attr_accessor :description
    @@amount = "?"

    #
    # Initializer to transform a +Hash+ into an Refund object
    #
    # @param [Hash] args
    def initialize(args=nil)
      @line_items = []
      return if args.nil?
      args.each do |k,v|
        instance_variable_set("@#{k}", v) unless v.nil?
      end
    end

    # @return [Boolean] true/false, depending if this instanciated object is valid
    def valid?
      validator = RefundValidator.new
      validator.valid?(self)
    end


  end

end

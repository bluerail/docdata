module Docdata
  #
  # Object representing a "Bank" object with attributes provided by Mollie
  #
  # @example
  #   Bank.new({
  #     :id => "0031",
  #     :name => "ABN AMRO"
  #   })
  class Bank
    # @return [String] The id of the bank provided by Mollie.
    attr_accessor :id
    # @return [String] The name of the bank.
    attr_accessor :name

    #
    # Initializer to transform a +Hash+ into an Bank object
    #
    # @param [Hash] values
    def initialize(values=nil)
      return if values.nil?

      @id = values[:id].to_s
      @name = values[:name].to_s
    end
  end
end

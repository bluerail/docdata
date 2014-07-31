module Docdata
  #
  # This class bundles all the needed logic and methods for IDEAL specific stuff.
  #
  class Ideal

    #
    # List of supported banks.
    #
    # @visibility public
    #
    # @example
    #   Docdata.banks
    #
    # For the lack of an available list of banks by Docdata,
    # this gem uses the list provided by competitor Mollie.
    # 
    # @return [Array<Docdata::Ideal>] list of supported +Bank+'s.
    def self.banks
      @source ||= open('https://secure.mollie.nl/xml/ideal?a=banklist')
      @response ||= Nokogiri::XML(@source)
      @list = []
      @response.xpath("//bank").each do |b|
        bank = Docdata::Bank.new(
          id: b.xpath("bank_id").first.content,
          name: b.xpath("bank_name").first.content
        )
        @list << bank
      end
      return @list
    end

  end
end

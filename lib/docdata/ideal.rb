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
      begin
        @source ||= open('https://secure.mollie.nl/xml/ideal?a=banklist')
      rescue 
        # in case the mollie API isn't available
        # use the cached version (august 2014) of the XML file
        @source = open("#{File.dirname(__FILE__)}/xml/bank-list.xml")
      end
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

class UmichCatalogItems
  attr_reader :docs
  def self.for(barcodes: [])
    new(CatalogSolrClient.client.get_docs_for_barcodes(barcodes))
  end

  def initialize(docs)
    @docs = docs
  end

  def item_for_barcode(barcode)
    doc = @docs.find { |doc| doc["barcode"].include?(barcode) }
    return nil if doc.nil?
    Item.new(doc: doc, barcode: barcode)
  end

  class Item
    attr_accessor :barcode
    def initialize(doc:, barcode:)
      @doc = doc
      @barcode = barcode
    end

    def callnumber
      umich_holding_item&.dig("callnumber")
    end

    def mms_id
      @doc["id"]
    end

    def title
      @doc["title_display"]&.first
    end

    def author
      @doc["main_author_display"]&.first
    end

    def oclc
      @doc["oclc"]
    end

    def description
      umich_holding_item&.dig("description")
    end

    def inventory_number
      umich_holding_item&.dig("inventory_number")
    end

    def umich_holding_item
      @umich_holding_item ||= JSON.parse(@doc["hol"]).filter do |x|
        !["HathiTrust Digital Library", "ELEC"].include?(x["library"])
      end&.pluck("items")&.flatten&.find { |y| y["barcode"] == @barcode }
    end

    def hathi_items
      @hathi_items ||= JSON.parse(@doc["hol"]).find do |x|
        x["library"] == "HathiTrust Digital Library"
      end&.dig("items")&.pluck("id")
    end

    def electronic_items
      @electronic_items ||= JSON.parse(@doc["hol"]).filter_map do |x|
        x["link"] if x["library"] == "ELEC"
      end
    end
  end
end

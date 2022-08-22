class ReportGenerator
  def initialize(barcodes: [])
    @barcodes = barcodes
  end

  def run
    output = [["barcode", "mms_id", "title", "author", "call number", "inventory number", "item description", "oclc numbers", "Umich Libraries with Items", "HathiTrust items", "other electronic items", "Total Libraries", "United States Libraries", "Libraries Outside of the United States"]]
    @barcodes.each do |barcode|
      umich_item = umich_catalog_items.item_for_barcode(barcode)
      next if umich_item.nil?
      worldcat_summary = WorldCatSummary.for(umich_item.oclc || [])
      output.push([
        umich_item.barcode,
        umich_item.mms_id,
        umich_item.title,
        umich_item.author,
        umich_item.callnumber,
        umich_item.inventory_number,
        umich_item.description,
        umich_item.oclc&.join(","),
        umich_item.umich_libraries&.join(","),
        umich_item.hathi_items&.join(","),
        umich_item.electronic_items&.join(","),
        worldcat_summary.total_libraries,
        worldcat_summary.united_states_libraries&.join(","),
        worldcat_summary.non_united_states_libraries&.join(",")
      ])
    end
    print(output)
  end

  def print(output)
    CSV.generate do |csv|
      output.each do |line|
        csv << line
      end
    end
  end

  def umich_catalog_items
    @umich_catalog_items ||= UmichCatalogItems.for(barcodes: @barcodes)
  end
end

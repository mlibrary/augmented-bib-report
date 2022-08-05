class ReportGenerator
  def initialize(barcodes: [])
    @barcodes = barcodes
  end

  def run
    @barcodes.each do |barcode|
      umich_item = umich_catalog_items.item_for_barcode(barcode)
      next if umich_item.nil?
      puts [umich_item.mms_id, umich_item.title, umich_item.author]
    end
    "done"
  end

  def umich_catalog_items
    @umich_catalog_items ||= UmichCatalogItems.for(barcodes: @barcodes)
  end
end

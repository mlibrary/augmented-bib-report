class ReportGenerator
  def initialize(barcodes: [])
    @barcodes = barcodes
    @umich_catalog_items = UmichCatalogItems.for(barcodes: @barcodes)
    Logger.new($stdout).info("fetched umich catalog items")
  end

  def run
    queue = Queue.new
    queue.push(header_row)

    barcode_queue = @barcodes.inject(Queue.new, :push)

    threads = Array.new(ENV.fetch(MAX_THREADS)) do
      Thread.new do
        until barcode_queue.empty?
          barcode = barcode_queue.shift
          umich_item = @umich_catalog_items.item_for_barcode(barcode)
          next if umich_item.nil?
          worldcat_summary = WorldCatSummary.for(umich_item.oclc || [])

          queue.push(
            format_line(umich_item: umich_item, worldcat_summary: worldcat_summary)
          )
        end
      end
    end

    threads.each(&:join)
    print(queue)
  end

  def header_row
    [
      "barcode",
      "MMS ID",
      "title",
      "author",
      "call number",
      "inventory number",
      "item description",
      "oclc numbers",
      "Umich Libraries with Items",
      "HathiTrust items",
      "Other Electronic Items",
      "Total Libraries",
      "United States Libraries",
      "Libraries Outside of the United States"
    ]
  end

  def format_line(umich_item:, worldcat_summary:)
    [
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
    ]
  end

  def print(queue)
    CSV.generate do |csv|
      queue.size.times do
        csv << queue.pop
      end
    end
  end
end

module CatalogSolrClient
  class Client
    def initialize
      @conn = Faraday.new(
        url: CatalogSolrClient.configuration.solr_url
      ) do |f|
        f.request :json
        #  f.request :retry, {max: 1, retry_statuses: [500]}
        f.response :json
      end
      @path_prefix = "/solr/#{CatalogSolrClient.configuration.core}"
    end

    def get_docs_for_barcodes(barcodes = [], slice = 300)
      return [] if barcodes.empty?
      chunks = barcodes.each_slice(slice).to_a
      chunks.map do |barcodes|
        query = {
          q: "barcode:(#{barcodes.join(" OR ")})",
          rows: slice
        }
        resp = @conn.public_send(:get, "#{@path_prefix}/select", query)
        resp.body&.dig("response", "docs")
      end.flatten
    end
  end
end

module CatalogSolrClient
  class Configuration
    attr_accessor :solr_url, :core
    def initialize
      @solr_url = ENV.fetch("CATALOG_SOLR")
      @core = "biblio"
    end
  end
end

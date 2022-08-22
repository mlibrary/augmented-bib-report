require "sinatra"
require "omniauth"
require "omniauth_openid_connect"
require "csv"
require "faraday"
require_relative "./lib/monkey_httpclient"
require_relative "./lib/omniauth_setup"
require_relative "./lib/catalog_solr_client"
require_relative "./lib/worldcat_client"
require_relative "./lib/worldcat_summary"
require_relative "./lib/umich_catalog_items"
require_relative "./lib/report_generator"

get "/" do
  erb :index
end

post "/report" do
  barcodes = params["barcodes"].split(",")
  content_type "application/csv"
  attachment "holdings_analyzer_#{Date.today.strftime("%Y%m%d")}.csv"
  ReportGenerator.new(barcodes: barcodes).run
end

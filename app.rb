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
require "byebug" if development?

get "/" do
  erb :index
end

post "/report" do
  barcodes = File.readlines(params[:barcodes][:tempfile]).filter_map do |line|
    line.strip unless line.match?(/[Bb]arcode/)
  end
  logger.info barcodes
  content_type "application/csv"
  attachment "holdings_analyzer_#{Date.today.strftime("%Y%m%d")}.csv"
  ReportGenerator.new(barcodes: barcodes).run
end

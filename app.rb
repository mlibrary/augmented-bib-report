require "sinatra"
require "omniauth"
require "omniauth_openid_connect"
require_relative "./lib/monkey_httpclient"
require_relative "./lib/omniauth_setup"
require_relative "./lib/catalog_solr_client"
require_relative "./lib/umich_catalog_items"

get "/" do
  "Hello World"
end

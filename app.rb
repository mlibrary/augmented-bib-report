class ToBeRemoved
  def test
    "test"
  end
end

require "sinatra"
require "omniauth"
require "omniauth_openid_connect"
require_relative "./lib/monkey_httpclient"
require_relative "./lib/omniauth_setup"

get "/" do
  "Hello World"
end

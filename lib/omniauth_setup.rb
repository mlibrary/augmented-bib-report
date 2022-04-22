enable :sessions
set :session_secret, ENV["RACK_COOKIE_SECRET"]

use OmniAuth::Builder do
  provider :openid_connect, {
    issuer: "https://weblogin.lib.umich.edu",
    discovery: true,
    client_auth_method: "jwks",
    scope: [:openid, :profile, :email],
    client_options: {
      identifier: ENV["WEBLOGIN_ID"],
      secret: ENV["WEBLOGIN_SECRET"],
      redirect_uri: "#{ENV["REPORT_BASE_URL"]}/auth/openid_connect/callback"
    }
  }
end
get "/auth/openid_connect/callback" do
  auth = request.env["omniauth.auth"]
  info = auth[:info]
  session[:authenticated] = true
  session[:expires_at] = Time.now.utc + 1.hour
  session[:uniqname] = info[:nickname]
  redirect session.delete(:path_before_login) || "/"
end

# :nocov:
get "/auth/failure" do
  "You are not authorized"
end
# :nocov:

get "/logout" do
  session.clear
  redirect "https://shibboleth.umich.edu/cgi-bin/logout?https://lib.umich.edu/"
end

get "/login" do
  redirect "/auth/openid_connect"
end

before do
  pass if ["auth", "logout", "login"].include? request.path_info.split("/")[1]

  if dev_login?
    session[:uniqname] = "mlibrary.acct.testing1@gmail.com" unless session[:uniqname]
    pass
  end

  session[:path_before_login] = request.path_info

  # authenticated but expired go relogin
  if session[:authenticated] && Time.now.utc > session[:expires_at]
    redirect "/auth/openid_connect"
  elsif !session[:authenticated]
    # for now, always authenticate
    redirect "/auth/openid_connect"
  end
end

helpers do
  def dev_login?
    ENV["WEBLOGIN_ON"] == "false" && settings.environment == :development
  end
end

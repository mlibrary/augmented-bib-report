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
  <<~HTML
    <h1>Logging You In...<h1>
    <script>
      window.onload = function(){
        document.forms['login_form'].submit();
      }
    </script>
    <form id='login_form' method='post' action='/auth/openid_connect'>
      <input type="hidden" name="authenticity_token" value='#{request.env["rack.session"]["csrf"]}'>
      <noscript>
        <button type="submit">Login</button>
      </noscript>
    </form>
  HTML
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
    redirect "login"
  elsif !session[:authenticated]
    # for now, always authenticate
    redirect "login"
  end
end

helpers do
  def dev_login?
    ENV["WEBLOGIN_ON"] == "false" && settings.environment == :development
  end
end

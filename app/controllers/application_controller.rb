class ApplicationController < ActionController::Base
  before_action :set_current_request_details
  before_action :authenticate


  def authenticate
    if authenticate_with_token || authenticate_with_cookies
      # Great! You're in
    elsif !performed?
      request_api_authentication || request_cookie_authentication
    end
  end

  def authenticate_with_token
    if session = authenticate_with_http_token { |token, _| Session.find_signed(token) }
      Current.session = session
    end
  end

  def authenticate_with_cookies
    if session = Session.find_by_id(cookies.signed[:session_token])
      Current.session = session
    end
  end

  def user_signed_in?
    authenticate_with_cookies || authenticate_with_token
  end

  helper_method :user_signed_in?
  

  def request_api_authentication
    request_http_token_authentication if request.format.json?
  end

  def request_cookie_authentication
    session[:return_path] = request.fullpath
    render 'sessions/new', status: :unauthorized, notice: "You need to sign in"
  end

  def set_current_request_details
    Current.user_agent = request.user_agent
    Current.ip_address = request.ip
  end
end

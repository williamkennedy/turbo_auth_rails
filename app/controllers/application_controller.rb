class ApplicationController < ActionController::Base
  include ActionController::HttpAuthentication::Token::ControllerMethods
  before_action :set_current_request_details
  before_action :authenticate

  private

  def authenticate
    puts "JSON #{request.format.json?}"
    if authenticate_with_token || authenticate_with_cookies
      # Great! You're in
    elsif !performed?
      request_api_authentication || request_cookie_authentication
    end
  end

  def authenticate_with_token
    puts "HEADERS: #{request.headers.inspect}"
    if session = authenticate_with_http_token  do |token, _|
      puts token
      puts _
      Session.find_signed(token)
    end
      Current.session = session
    end
  end

  def authenticate_with_cookies
    if session = Session.find_by_id(cookies.signed[:session_token])
      Current.session = session
    end
  end

  def request_api_authentication
    puts request.format.json?
    request_http_token_authentication if request.format.json?
  end

  def request_cookie_authentication
    redirect_to sign_in_path, status: :unauthorized
  end

  def set_current_request_details
    Current.user_agent = request.user_agent
    Current.ip_address = request.ip
  end
end

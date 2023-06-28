class Api::V1::SessionsController < Api::ApplicationController
  skip_before_action :authenticate, only: :create

  before_action :set_session, only: %i[ show destroy ]

  def index
    render json: Current.user.sessions.order(created_at: :desc)
  end

  def show
    render json: @session
  end

  def create
    user = User.find_by(email: params[:email])

    if user && user.authenticate(params[:password])
      @session = user.sessions.create!
      response.set_header "X-Session-Token", @session.signed_id
      cookies.signed.permanent[:session_token] = { value: @session.id, httponly: true }

      render json: @session, status: :created
    else
      render json: { error: "That email or password is incorrect" }, status: :unauthorized
    end
  end

  def destroy
    @session.destroy
  end

  private
  def set_session
    @session = Current.user.sessions.find(params[:id])
  end
end

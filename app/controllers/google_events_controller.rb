include ERB::Util

class GoogleEventsController < ApplicationController
  before_action :authorize_startup
  before_action :set_my_company
  swagger_controller :google_events, "Startup's google events"

  swagger_api :index do
    summary "Retrieve 6 closest events"
    param :path, :user_id, :integer, :required, "User id"
    param :path, :company_id, :integer, :required, "Company id"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :ok
    response :unauthorized
    response :forbidden
    response :not_found
  end
  def index
    google_exchange = GoogleExchange.new
    events = google_exchange.get_events(@user.access_token, @user.google_calendar_id)

    if "error".in? events
      token = google_exchange.update_token(@user.refresh_token)
      if "error".in? token
        render json: token, status: :unprocessable_entity and return
      end

      events = google_exchange.get_events(@user.access_token, @user.google_calendar_id)
      if "error".in? events
        render json: token, status: :unprocessable_entity and return
      end
    end

    render json: events, status: :ok
  end

  swagger_api :create do
    summary "Set google auth code"
    param :path, :user_id, :integer, :required, "User id"
    param :path, :company_id, :integer, :required, "Company id"
    param :form, :access_token, :string, :required, "Google auth code"
    param :form, :refresh_token, :string, :required, "Google refresh token"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :ok
    response :unauthorized
    response :forbidden
    response :not_found
    response :unprocessable_entity
  end
  def create
    unless params[:access_token]
      render json: {access_token: ["can't be blank"]}, status: :unprocessable_entity and return
    end

    unless params[:refresh_token]
      render json: {refresh_token: ["can't be blank"]}, status: :unprocessable_entity and return
    end

    if @user.update(user_tokens_params)
      google_exchange = GoogleExchange.new
      calendars = google_exchange.get_calendars(@user.access_token)

      if "error".in? calendars
        render json: calendars, status: :unprocessable_entity
      else
        render json: calendars, status: :ok
      end
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  swagger_api :set_google_calendar do
    summary "Set google calendar id"
    param :path, :user_id, :integer, :required, "User id"
    param :path, :company_id, :integer, :required, "Company id"
    param :form, :google_calendar_id, :string, :required, "Google google calendar id"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :ok
    response :unauthorized
    response :forbidden
    response :not_found
    response :unprocessable_entity
  end
  def set_google_calendar
    unless params[:google_calendar_id]
      render json: {google_calendar_id: ["can't be blank"]}, status: :unprocessable_entity and return
    end

    @user.google_calendar_id = params[:google_calendar_id]
    if @user.save
      render status: :ok
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  private
    def authorize_startup
      @user = AuthorizationHelper.authorize_startup(request)

      if @user == nil
        render status: :unauthorized and return
      end

      if @user.id != params[:user_id].to_i
        render json: {errors: :WRONG_USER_ID}, status: :forbidden and return
      end
    end

    def set_my_company
      @company = @user.company

      unless @company
        render json: {errors: :COMPANY_NOT_FOUND}, status: :not_found and return
      end

      if @company.id != params[:company_id].to_i
        render json: {errors: :WRONG_COMPANY_ID}, status: :forbidden and return
      end

      if @company.user_id != @user.id
        render json: {errors: :COMPANY_NOT_BELONG_TO_USER}, status: :forbidden and return
      end
    end

    def user_tokens_params
      params.permit(:access_token, :refresh_token)
    end
end

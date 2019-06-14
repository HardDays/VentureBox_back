class StartupNewsController < ApplicationController
  before_action :authorize_investor, only: [:index]
  before_action :authorize_startup, only: [:my_news, :create, :destroy]
  before_action :set_company, only: [:company_news]
  before_action :set_my_company, only: [:my_news, :create, :destroy]
  before_action :set_startup_news, only: [:destroy]
  before_action :check_startup_news, only: [:destroy]
  swagger_controller :startup_news, "Startup news"

  # GET /startup_news
  swagger_api :index do
    summary "Retrieve startup news"
    param :query, :company_id, :integer, :optional, "Company id"
    param :query, :limit, :integer, :optional, "Limit"
    param :query, :offset, :integer, :optional, "Offset"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :ok
    response :forbidden
    response :unauthorized
  end
  def index
    company_ids = @user.invested_companies.pluck(:company_id)
    company_ids += @user.interesting_companies.pluck(:company_id)
    @startup_news = StartupNews.where(company_id: company_ids)

    if params[:company_id]
      @startup_news = @startup_news.where(company_id: params[:company_id])
    end

    render json: {
      count: @startup_news.count,
      items: @startup_news.order(created_at: :desc).limit(params[:limit]).offset(params[:offset])
    }, status: :ok
  end

  # GET /companies/1/startup_news
  swagger_api :company_news do
    summary "Retrieve company news"
    param :path, :id, :integer, :required, "Company id"
    param :query, :limit, :integer, :optional, "Limit"
    param :query, :offset, :integer, :optional, "Offset"
    response :ok
    response :not_found
  end
  def company_news
    @startup_news = @company.startup_news.all

    render json: {
      count: @startup_news.count,
      items: @startup_news.limit(params[:limit]).offset(params[:offset])
    }, status: :ok
  end

  # GET /users/1/companies/1/startup_news
  swagger_api :my_news do
    summary "Retrieve my startup's news"
    param :path, :user_id, :integer, :required, "User id"
    param :path, :company_id, :integer, :required, "Company id"
    param :query, :limit, :integer, :optional, "Limit"
    param :query, :offset, :integer, :optional, "Offset"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :ok
    response :forbidden
    response :unauthorized
  end
  def my_news
    render json: {
      count: @company.startup_news.count,
      items: @company.startup_news.limit(params[:limit]).offset(params[:offset])
    }, status: :ok
  end

  # POST /users/1/companies/1/startup_news
  swagger_api :create do
    summary "Create startup news"
    param :path, :user_id, :integer, :required, "User id"
    param :path, :company_id, :integer, :required, "Company id"
    param :form, :text, :string, :required, "News text"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :created
    response :unprocessable_entity
    response :forbidden
    response :unauthorized
  end
  def create
    @startup_news = StartupNews.new(startup_news_params)
    @startup_news.company_id = @company.id

    if @startup_news.save
      render json: @startup_news, status: :created
    else
      render json: @startup_news.errors, status: :unprocessable_entity
    end
  end

  # DELETE /users/1/companies/1/startup_news/1
  swagger_api :destroy do
    summary "Retrieve my startup new delete"
    param :path, :user_id, :integer, :required, "User id"
    param :path, :company_id, :integer, :required, "Company id"
    param :path, :id, :integer, :required, "News id"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :ok
    response :unprocessable_entity
    response :forbidden
    response :unauthorized
  end
  def destroy
    @startup_news.destroy

    render status: :ok
  end

  private
    def authorize_investor
      @user = AuthorizationHelper.authorize_investor(request)

      if @user == nil
        render status: :unauthorized and return
      end
    end

    def authorize_startup
      @user = AuthorizationHelper.authorize_startup(request)

      if @user == nil
        render status: :unauthorized and return
      end

      if @user.id != params[:user_id].to_i
        render json: {errors: :WRONG_USER_ID}, status: :forbidden and return
      end
    end

    def set_company
      begin
        @company = Company.find(params[:id])
      rescue
        render status: :not_found and return
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

    def set_startup_news
      begin
        @startup_news = StartupNews.find(params[:id])
      rescue
        render status: :not_found and return
      end
    end

    def check_startup_news
      if @company.id != @startup_news.company_id
        render json: {errors: :ITEM_NOT_BELONG_TO_COMPANY}, status: :forbidden and return
      end
    end

    def startup_news_params
      params.permit(:company_id, :text)
    end
end

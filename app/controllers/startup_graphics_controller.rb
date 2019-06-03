class StartupGraphicsController < ApplicationController
  before_action :authorize_startup
  before_action :set_company
  before_action :check_company_ownership
  swagger_controller :startup_graphics, "Startup dashboard graphics"

  swagger_api :sales do
    summary "Startup sales pie"
    param :path, :user_id, :integer, :required, "User id"
    param :path, :company_id, :integer, :required, "Company id"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :ok
    response :not_found
    response :forbidden
    response :unauthorized
  end
  def sales
    @products = @company.company_items.all

    if @products.count > 0
      value = 100 / @products.count
      result = []
      @products.each do |product|
        result.append({name: product.name, value: value})
      end

      render json: {sales: result}, status: :ok
    else
      render json: {sales: []}, status: :ok
    end
  end

  swagger_api :total_earn do
    summary "Startup total earn value"
    param :path, :user_id, :integer, :required, "User id"
    param :path, :company_id, :integer, :required, "Company id"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :ok
    response :not_found
    response :forbidden
    response :unauthorized
  end
  def total_earn
    render json: {total_earn: 1000000}, status: :ok
  end

  swagger_api :total_investment do
    summary "Startup total investment value"
    param :path, :user_id, :integer, :required, "User id"
    param :path, :company_id, :integer, :required, "Company id"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :ok
    response :not_found
    response :forbidden
    response :unauthorized
  end
  def total_investment
    @investments = @company.invested_companies.sum(:investment)
    @investments += @company.investment_amount

    render json: {total_investment: @investments}, status: :ok
  end

  swagger_api :score do
    summary "Startup score value"
    param :path, :user_id, :integer, :required, "User id"
    param :path, :company_id, :integer, :required, "Company id"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :ok
    response :not_found
    response :forbidden
    response :unauthorized
  end
  def score
    @signum_exchange = SignumExchange.new
    @score = @signum_exchange.get_index(@company.website)

    render json: {score: @score}, status: :ok
  end

  swagger_api :evaluation do
    summary "Startup evaluation histogram"
    param :path, :user_id, :integer, :required, "User id"
    param :path, :company_id, :integer, :required, "Company id"
    param_list :query, :period, :string, :required, "Period", ["month", "year", "all"]
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :ok
    response :not_found
    response :forbidden
    response :unauthorized
  end
  def evaluation
    render status: :ok
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

    def set_company
      begin
        @company = Company.find(params[:company_id])
      rescue
        render status: :not_found and return
      end
    end

    def check_company_ownership
      unless @company.user_id == @user.id
        render json: {errors: :WRONG_COMPANY_ID}, status: :forbidden and return
      end
    end
end

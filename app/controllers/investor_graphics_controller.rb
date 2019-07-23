class InvestorGraphicsController < ApplicationController
  before_action :authorize_investor
  before_action :set_company
  swagger_controller :investor_graphics, "Investor dashboard graphics"

  swagger_api :total_current_value do
    summary "Total current value graph"
    param :path, :user_id, :integer, :required, "User id"
    param_list :query, :period, :string, :required, "Period", ["month", "year", "all"]
    param :query, :company_id, :integer, :optional, "Company filter"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :ok
    response :not_found
    response :forbidden
    response :unauthorized
  end
  def total_current_value
    unless params[:period]
      params[:period] = "month"
    end

    if params[:period] == 'all'
      axis, date_range, step = GraphHelper.get_all_period_info(Time.at(@user.created_at).to_datetime)
    else
      if params[:period] == "month"
        step = "day"
      else
        step = "month"
      end

      axis = GraphHelper.axis(params[:period], step)
      date_range = GraphHelper.axis_dates(params[:period], step)
    end

    @invested_companies = Company.joins(:invested_companies).where(invested_companies: {investor_id: @user.id})
    if params[:company_id]
      @invested_companies = @invested_companies.where(invested_companies: {company_id: params[:company_id]})
    end
    @invested_companies = @invested_companies.distinct

    result = {}
    date_range.each do |date_value|
      date_str = date_value.beginning_of_hour.strftime(GraphHelper.date_to_axis_str(step))

      result[date_str] = 0
      @invested_companies.each do |investment|
        result[date_str] += investment.get_evaluation_on_date(
          investment.created_at, date_value.end_of_hour)
      end
    end

    render json: {
      axis: axis,
      total_current_values: result,
    }, status: :ok
  end

  swagger_api :amount_invested do
    summary "Amount invested value"
    param :path, :user_id, :integer, :required, "User id"
    param :query, :company_id, :integer, :optional, "Company filter"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :ok
    response :not_found
    response :forbidden
    response :unauthorized
  end
  def amount_invested
    @investments = @user.invested_companies

    if params[:company_id]
      @investments = @investments.where(company_id: @company.id)
    end

    render json: {amount_invested: @investments.sum(:investment)}, status: :ok
  end

  swagger_api :rate_of_return do
    summary "Rate of return graph"
    param :path, :user_id, :integer, :required, "User id"
    param_list :query, :period, :string, :required, "Period", ["month", "year", "all"]
    param :query, :company_id, :integer, :optional, "Company filter"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :ok
    response :not_found
    response :forbidden
    response :unauthorized
  end
  def rate_of_return
    unless params[:period]
      params[:period] = "month"
    end

    if params[:period] == 'all'
      axis, date_range, step = GraphHelper.get_all_period_info(Time.at(@user.created_at).to_datetime)
    else
      if params[:period] == "month"
        step = "day"
      else
        step = "month"
      end

      axis = GraphHelper.axis(params[:period], step)
      date_range = GraphHelper.axis_dates(params[:period], step)
    end

    @invested_companies = Company.joins(:invested_companies).where(invested_companies: {investor_id: @user.id})
    if params[:company_id]
      @invested_companies = @invested_companies.where(invested_companies: {company_id: params[:company_id]})
    end
    @invested_companies = @invested_companies.distinct

    result = {}
    date_range.each do |date_value|
      date_str = date_value.beginning_of_hour.strftime(GraphHelper.date_to_axis_str(step))

      result[date_str] = 0
      @invested_companies.each do |company|
        result[date_str] += company.get_evaluation_on_date(
            company.created_at, date_value.end_of_hour
        ) * @user.invested_companies.where(
            company_id: company.id, created_at: company.created_at..date_value.end_of_hour
        ).sum(:evaluation) * 1.00
      end

      result[date_str] = ((result[date_str] / @user.invested_companies.where(
          created_at: @user.created_at..date_value.end_of_hour
      ).sum(:investment)) - 100.00).round(1)
    end

    render json: {
      axis: axis,
      rate_of_return: result,
    }, status: :ok
  end

  private
    def authorize_investor
      @user = AuthorizationHelper.authorize_investor(request)

      if @user == nil
        render status: :unauthorized and return
      end

      if @user.id != params[:user_id].to_i
        render json: {errors: :WRONG_USER_ID}, status: :forbidden and return
      end
    end


    def set_company
      if params[:company_id]
        begin
          @company = Company.find(params[:company_id])
        rescue
          render status: :not_found and return
        end
      end
    end
end

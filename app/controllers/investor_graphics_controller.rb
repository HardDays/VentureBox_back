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

    type = params[:period]
    if params[:period] == 'all'
      dates = [Time.at(@user.created_at).to_datetime, DateTime.now]
      diff = Time.diff(dates[0], dates[1])
      if diff[:month] > 0
        new_step = 'year'
      elsif diff[:week] > 0
        new_step = 'month'
      elsif diff[:day] > 0
        new_step = 'week'
      else
        new_step = 'day'
      end

      axis = GraphHelper.custom_axis(new_step, dates)
      date_range = GraphHelper.custom_axis_dates(new_step, dates)
      type = new_step
    else
      axis = GraphHelper.axis(params[:period])
      date_range = GraphHelper.axis_dates(params[:period])
    end

    @invested_companies = @user.invested_companies
    if params[:company_id]
      @invested_companies = @invested_companies.where(company_id: params[:company_id])
    end

    result = {}
    date_range.each do |date_value|
      date_str = date_value.beginning_of_hour.strftime(GraphHelper.type_str(type))

      result[date_str] = 0
      @invested_companies.each do |investment|
        result[date_str] += investment.company.get_evaluation_on_date(
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

    type = params[:period]
    if params[:period] == 'all'
      dates = [Time.at(@user.created_at).to_datetime, DateTime.now]
      diff = Time.diff(dates[0], dates[1])
      if diff[:month] > 0
        new_step = 'year'
      elsif diff[:week] > 0
        new_step = 'month'
      elsif diff[:day] > 0
        new_step = 'week'
      else
        new_step = 'day'
      end

      axis = GraphHelper.custom_axis(new_step, dates)
      date_range = GraphHelper.custom_axis_dates(new_step, dates)
      type = new_step
    else
      axis = GraphHelper.axis(params[:period])
      date_range = GraphHelper.axis_dates(params[:period])
    end

    @invested_companies = @user.invested_companies
    if params[:company_id]
      @invested_companies = @invested_companies.where(company_id: params[:company_id])
    end

    # TODO: надо делить то, что заработали на эту дату после вычета всех налогов на колличество инвестиций
    result = {}
    date_range.each do |date_value|
      result[date_value.strftime(GraphHelper.type_str(type))] = 0
      @invested_companies.each do |investment|
        result[date_value.strftime(GraphHelper.type_str(type))] = Random.rand(100)
      end
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

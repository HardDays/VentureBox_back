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
      dates = [@user.created_at, DateTime.now]
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
      dates_range = dates[0]..dates[1]
      params[:period] = new_step
    else
      axis = GraphHelper.axis(params[:period])
      dates_range = GraphHelper.sql_date_range(params[:period])
    end

    # events = Event.where(
    #   created_at: dates_range
    # ).order(:is_crowdfunding_event, :created_at).to_a.group_by(
    #   &:is_crowdfunding_event
    # ).each_with_object({}) {
    #   |(k, v), h| h[k] = v.group_by{ |e| e.created_at.strftime(GraphHelper.type_str(params[:period])) }
    # }.each { |(k, h)|
    #   h.each { |m, v|
    #     h[m] = v.count
    #   }
    # }

    render json: {
      axis: axis,
      total_current_value: [],
    }, status: :ok
  end

  swagger_api :amount_of_companies do
    summary "Amount of companies value"
    param :path, :user_id, :integer, :required, "User id"
    param :query, :company_id, :integer, :optional, "Company filter"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :ok
    response :not_found
    response :forbidden
    response :unauthorized
  end
  def amount_of_companies
    unless params[:period]
      params[:period] = "month"
    end

    render json: {amount_of_companies: 1000000}, status: :ok
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
    unless params[:period]
      params[:period] = "month"
    end

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

    render status: :ok
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

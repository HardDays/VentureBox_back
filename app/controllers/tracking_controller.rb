class TrackingController < ApplicationController
  before_action :authorize_investor, only: [:investor]
  before_action :authorize_startup, only: [:startup]
  swagger_controller :tracking, "Tracking"

  @@step = 'month'

  swagger_api :startup do
    summary "Retrieve startup tracking info"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :ok
    response :forbidden
    response :unauthorized
  end
  def startup
    dates = [DateTime.now.prev_month(2), DateTime.now.next_month(2)]

    axis = GraphHelper.custom_axis(dates, @@step)
    date_range = GraphHelper.custom_axis_dates(dates, @@step)

    result = {}
    investors = User.joins(:invested_companies).where(invested_companies: {company_id: @user.company.id}).uniq

    investors.each do |investor|
      investor_full_name = "#{investor.name} #{investor.surname}"
      unless investor_full_name.in? result
        result[investor_full_name] = {}
      end

      investments = investor.invested_companies.where(invested_companies: {company_id: @user.company.id})
      result[investor_full_name]["total_investment"] = investments.sum("invested_companies.investment")

      total_payed = 0
      investments.each do |investment|
        months_count = get_months_count(investment.date_from, investment.date_to)

        date_range.each do |date|
          date_str = date.strftime(GraphHelper.date_to_axis_str(@@step))
          unless date_str.in? result[investor_full_name]
            result[investor_full_name][date_str] = {
              amount: 0,
              payed: false
            }
          end

          current_date = date.utc.beginning_of_month
          investment_start = investment.date_from.utc.beginning_of_month
          investment_end = investment.date_to.utc.beginning_of_month
          if current_date >= investment_start and current_date <= investment_end
            result[investor_full_name][date_str][:amount] += (investment.investment / months_count)
          end

          if investment.investment_payeds.where(date: date.utc.beginning_of_month).exists?
            result[investor_full_name][date_str][:payed] = true
          end
        end
      end
      result[investor_full_name]["debt"] = (result[investor_full_name]["total_investment"] -
        InvestmentPayed.where(invested_company: investments).sum('amount'))
    end

    render json: {
      axis: axis,
      investors: result
    }, status: :ok
  end

  swagger_api :investor do
    summary "Retrieve investor tracking info"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :ok
    response :forbidden
    response :unauthorized
  end
  def investor
    dates = [DateTime.now.prev_month(2), DateTime.now.next_month(2)]

    axis = GraphHelper.custom_axis(dates, @@step)
    date_range = GraphHelper.custom_axis_dates(dates, @@step)

    result = {}
    companies = Company.joins(:invested_companies).where(invested_companies: {investor_id: @user.id}).uniq

    companies.each do |company|
      company_full_name = "#{company.company_name}"
      unless company_full_name.in? result
        result[company_full_name] = {}
      end

      investments = @user.invested_companies.where(invested_companies: {company_id: company.id})
      result[company_full_name]["total_investment"] = investments.sum("invested_companies.investment")

      total_payed = 0
      investments.each do |investment|
        months_count = get_months_count(investment.date_from, investment.date_to)

        date_range.each do |date|
          date_str = date.strftime(GraphHelper.date_to_axis_str(@@step))
          unless date_str.in? result[company_full_name]
            result[company_full_name][date_str] = {
              amount: 0,
              payed: false
            }
          end

          current_date = date.utc.beginning_of_month
          investment_start = investment.date_from.utc.beginning_of_month
          investment_end = investment.date_to.utc.beginning_of_month
          if current_date >= investment_start and current_date <= investment_end
            result[company_full_name][date_str][:amount] += (investment.investment / months_count)
          end

          if investment.investment_payeds.where(date: date.utc.beginning_of_month).exists?
            result[company_full_name][date_str][:payed] = true
          end
        end
      end
      result[company_full_name]["debt"] = (result[company_full_name]["total_investment"] -
        InvestmentPayed.where(invested_company: investments).sum('amount'))
    end

    render json: {
      axis: axis,
      companies: result
    }, status: :ok
  end

  private
  def authorize_startup
    @user = AuthorizationHelper.authorize_startup(request)

    if @user == nil
      render status: :unauthorized and return
    end
  end

  def authorize_investor
    @user = AuthorizationHelper.authorize_investor(request)

    if @user == nil
      render status: :unauthorized and return
    end
  end

  def get_months_count(date_start, date_end)
    diff = Time.diff(date_start, date_end)

    if diff[:day] > 0
      diff[:month] + 1
    else
      diff[:month]
    end
  end
end

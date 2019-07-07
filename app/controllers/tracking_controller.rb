class TrackingController < ApplicationController
  before_action :authorize_investor, only: [:investor, :mark_payed]
  before_action :set_investment, only: [:mark_payed]
  before_action :authorize_startup, only: [:startup]
  swagger_controller :tracking, "Tracking"

  @@step = 'month'

  swagger_api :startup do
    summary "Retrieve startup tracking info"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :ok
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
      result[company_full_name]["company_id"] = company.id
    end

    render json: {
      axis: axis,
      companies: result
    }, status: :ok
  end

  swagger_api :mark_payed do
    summary "Mark month payed"
    param :form, :date, :string, :required, "Month datetime"
    param :form, :company_id, :integer, :required, "Investment id"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :created
    response :not_found
    response :unauthorized
    response :unprocessable_entity
  end
  def mark_payed
    payments = []
    @invested_companies.each do |company|
      months_count = get_months_count(company.date_from, company.date_to)

      @investment_payed = InvestmentPayed.new(investment_payed_params)
      @investment_payed.invested_company_id = company.id
      @investment_payed.amount = (company.investment / months_count)

      if @investment_payed.save
        payments << @investment_payed
      else
        payments.each do |payment|
          payment.destroy
        end

        render json: @investment_payed.errors, status: :unprocessable_entity and return
      end
    end

    render status: :created
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

  def set_investment
    @invested_companies = InvestedCompany.where(company_id: params[:company_id])

    unless @invested_companies.exists?
      render status: :not_found and return
    end
  end

  def get_months_count(date_start, date_end)
    diff = Time.diff(date_start, date_end)

    result = diff[:month]

    if diff[:day] > 0
      result += 1
    end

    if diff[:year] > 0
      diff[:year] * 12 + result
    elsif diff[:month] > 0
      result
    else
      1
    end
  end

  def investment_payed_params
    params.permit(:date)
  end
end

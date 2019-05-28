class InvestedCompaniesController < ApplicationController
  before_action :authorize_investor, only: [:index, :create]
  before_action :authorize_startup, only: [:my_investors]
  before_action :set_company, only: [:create, :my_investors]
  before_action :check_company_ownership, only: [:my_investors]
  before_action :delete_from_interesting, only: [:create]
  swagger_controller :invested_companies, "Invested companies"

  # GET /invested_companies
  swagger_api :index do
    summary "Retrieve invested companies list"
    param :query, :limit, :integer, :optional, "Limit"
    param :query, :offset, :integer, :optional, "Offset"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :ok
    response :unauthorized
  end
  def index
    @invested_companies = @user.invested_companies.all

    render json: {
      count: @invested_companies.count,
      items: @invested_companies.limit(params[:limit]).offset(params[:offset])
    }, list: true, status: :ok
  end

  # GET /users/1/companies/1/invested_companies
  swagger_api :my_investors do
    summary "Retrieve my investors list"
    param :path, :user_id, :integer, :required, "User id"
    param :path, :id, :integer, :required, "Company_id"
    param :query, :limit, :integer, :optional, "Limit"
    param :query, :offset, :integer, :optional, "Offset"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :ok
    response :unauthorized
  end
  def my_investors
    @invested_companies = @company.invested_companies.all

    render json: {
      count: @invested_companies.count,
      items: @invested_companies.limit(params[:limit]).offset(params[:offset])
    }, list: true, investor: true, status: :ok
  end

  # POST /companies/1/invested_companies
  swagger_api :create do
    summary "Invest into company"
    param :path, :company_id, :integer, :required, "Company id"
    param :form, :investment, :integer, :required, "Investment amount"
    param :form, :evaluation, :integer, :required, "Evaluation"
    param :form, :contact_email, :string, :optional, "Contact email"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :created
    response :unauthorized
    response :not_found
    response :unprocessable_entity
  end
  def create
    @invested_company = InvestedCompany.new(invested_company_params)
    @invested_company.company_id = @company.id
    @invested_company.investor_id = @user.id

    unless params[:contact_email]
      @invested_company.contact_email = @user.email
    end

    if @invested_company.save
      render json: @invested_company, status: :created
    else
      render json: @invested_company.errors, status: :unprocessable_entity
    end
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

      unless @user.id == params[:user_id].to_i
        render status: :forbidden and return
      end
    end

    def set_company
      begin
        @company = Company.find(params[:id])
      rescue
        render status: :not_found and return
      end
    end

    def check_company_ownership
      unless @company.user_id == @user.id
        render status: :forbidden and return
      end
    end

    def delete_from_interesting
      interesting_item = InterestingCompany.where(company_id: @company.id, investor_id: @user.id).first

      if interesting_item
        interesting_item.destroy
      end
    end

    def invested_company_params
      params.permit(:contact_email, :investment, :evaluation)
    end
end
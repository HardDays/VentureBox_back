class InterestingCompaniesController < ApplicationController
  before_action :authorize_investor
  before_action :set_company, only: [:create]
  before_action :set_interesting_company, only: [:destroy]
  before_action :check_investment, only: [:create]
  swagger_controller :interesting_companies, "Interesting companies"

  # GET /interesting_companies
  swagger_api :index do
    summary "Retrieve interested in list"
    param :query, :limit, :integer, :optional, "Limit"
    param :query, :offset, :integer, :optional, "Offset"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :ok
    response :unauthorized
  end
  def index
    @interesting_companies = @user.interesting_companies.all

    render json: {
      count: @interesting_companies.count,
      items: @interesting_companies.limit(params[:limit]).offset(params[:offset])
    }, status: :ok
  end

  # POST /companies/1/interesting_companies
  swagger_api :create do
    summary "Add company to interesting list"
    param :path, :id, :integer, :required, "Company id"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :created
    response :unauthorized
    response :not_found
  end
  def create
    @interesting_company = InterestingCompany.new
    @interesting_company.investor_id = @user.id
    @interesting_company.company_id = @company.id

    if @interesting_company.save
      render json: @interesting_company, status: :created, location: @interesting_company
    else
      render json: @interesting_company.errors, status: :unprocessable_entity
    end
  end

  # DELETE /interesting_companies/1
  swagger_api :destroy do
    summary "Delete company from interested list"
    param :path, :id, :integer, :required, "Interested item id"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :ok
    response :unauthorized
    response :not_found
    response :forbidden
  end
  def destroy
    @interesting_company.destroy

    render status: :ok
  end

  private
    def authorize_investor
      @user = AuthorizationHelper.authorize_investor(request)

      if @user == nil
        render status: :unauthorized and return
      end
    end

    def set_company
      begin
        @company = Company.find(params[:id])
      rescue
        render status: :not_found and return
      end
    end

    def set_interesting_company
      begin
        @interesting_company = InterestingCompany.find(params[:id])

        unless @interesting_company.investor_id == @user.id
          render status: :forbidden and return
        end
      rescue
        render status: :not_found and return
      end
    end

    def check_investment
      is_invested = InvestedCompany.where(investor_id: @user.id, company_id: @company.id).exists?

      if is_invested
        render json: {errors: :ALREADY_INVESTED}, status: :forbidden and return
      end
    end
end

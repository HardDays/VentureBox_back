class CompaniesController < ApplicationController
  before_action :authorize_investor, only: [:index, :investor_companies]
  before_action :authorize_startup, only: [:my, :my_image, :update]
  before_action :set_company, only: [:my, :show, :image, :my_image, :update]
  before_action :check_company_ownership, only: [:my, :my_image, :update]
  swagger_controller :company, "Startup company"

  # GET /companies
  swagger_api :index do
    summary "Retrieve companies"
    param :query, :limit, :integer, :optional, "Limit"
    param :query, :offset, :integer, :optional, "Offset"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :ok
    response :unauthorized
  end
  def index
    @my_companies = @user.invested_companies.pluck(:company_id)
    @companies = Company.where.not(id: @my_companies.uniq)

    render json: {
      count: @companies.count,
      items: @companies.limit(params[:limit]).offset(params[:offset])
    }, investor_list: true, investor_id: @user.id, status: :ok
  end

  # GET /companies/1
  swagger_api :show do
    summary "Retrieve company info"
    param :path, :id, :integer, :required, "Company id"
    param :header, 'Authorization', :string, :optional, 'Authentication token'
    response :ok
    response :unauthorized
    response :not_found
  end
  def show
    investor_id = nil
    @user = AuthorizationHelper.authorize_investor(request)
    if @user
      investor_id = @user.id
    end

    render json: @company, investor_id: investor_id, status: :ok
  end

  # GET /companies/1/image
  swagger_api :image do
    summary "Get company image"
    param :path, :id, :integer, :required, "Company id"
    param :query, :width, :integer, :optional, "Width to crop"
    param :query, :height, :integer, :optional, "Height to crop"
    response :ok
    response :unauthorized
    response :not_found
  end
  def image
    @image = @company.company_image
    unless @image
      render status: :not_found and return
    end

    if params[:width] and params[:height]
      resized = ResizedCompanyImage.find_by(company_image_id: @image.id, width: params[:width], height: params[:height])
      unless resized
        resized = ImageHelper.resize_company_image(@image.id, @image.base64, params[:width], params[:height])
      end

      @image = resized
    end

    send_data Base64.decode64(@image.base64.gsub(/^data:image\/[a-z]+;base64,/, '')), :type => 'image/png', :disposition => 'inline'
  end

  # GET /companies/my
  swagger_api :investor_companies do
    summary "Retrieve investor companies"
    param_list :query, :type, :string, :optional, "Type of companies", ["invested", "interested"]
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :ok
    response :unauthorized
  end
  def investor_companies
    @invested_companies = @user.invested_companies.distinct(:company_id)
    @interested_companies = @user.interesting_companies.distinct(:company_id)

    if params[:type] == "invested"
      @companies = @invested_companies
    elsif params[:type] == "interested"
      @companies = @interested_companies
    else
      @companies = @interested_companies + @invested_companies
    end

    render json: @companies, investor_companies: true, status: :ok
  end

  # GET /users/1/companies/1
  swagger_api :my do
    summary "Retrieve my company info"
    param :path, :user_id, :integer, :required, "Startup user id"
    param :path, :id, :integer, :required, "Company id"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :ok
    response :forbidden
    response :unauthorized
    response :not_found
  end
  def my
    render json: @company, my: true, status: :ok
  end

  # GET /users/1/companies/1/image
  swagger_api :my_image do
    summary "Get my company image"
    param :path, :user_id, :integer, :required, "Startup user id"
    param :path, :id, :integer, :required, "Company id"
    param :query, :width, :integer, :optional, "Width to crop"
    param :query, :height, :integer, :optional, "Height to crop"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :ok
    response :unauthorized
    response :not_found
  end
  def my_image
    @image = @company.company_image
    unless @image
      render status: :not_found and return
    end

    if params[:width] and params[:height]
      resized = ResizedCompanyImage.find_by(company_image_id: @image.id, width: params[:width], height: params[:height])
      unless resized
        resized = ImageHelper.resize_company_image(@image.id, @image.base64, params[:width], params[:height])
      end

      @image = resized
    end

    send_data Base64.decode64(@image.base64.gsub(/^data:image\/[a-z]+;base64,/, '')), :type => 'image/png', :disposition => 'inline'
  end

  # PATCH/PUT /users/1/companies/1
  swagger_api :update do
    summary "Update company info"
    param :path, :user_id, :integer, :required, "User id"
    param :path, :id, :integer, :required, "Company id"
    param :form, :website, :string, :optional, "Website"
    param :form, :description, :string, :optional, "Description"
    param :form, :contact_email, :string, :optional, "Contact email"
    param :form, :image, :string, :optional, "Logo"
    param_list :form, :stage_of_funding, :string, :optional, "Stage of funding", ["idea", "pre_seed", "seed", "serial_a", "serial_b", "serial_c"]
    param :form, :investment_amount, :integer, :optional, "Investment amount"
    param :form, :equality_amount, :integer, :optional, "Equality amount"
    param :form, :team_members, :string, :optional, "Team members [{team_member_name: name, c_level: cto}]"
    param :form, :is_interested_in_access, :boolean, :optional, ""
    param :form, :is_interested_in_insights, :boolean, :optional, ""
    param :form, :is_interested_in_capital, :boolean, :optional, ""
    param :form, :is_interested_in_marketplace, :boolean, :optional, ""
    param :form, :markets, :string, :optional, "Markets"
    param :form, :founded_in, :integer, :optional, "Year of foundation"
    param :form, :is_revenue_consumer, :boolean, :optional, ""
    param :form, :is_revenue_wholesale, :boolean, :optional, ""
    param :form, :is_revenue_other, :boolean, :optional, ""
    param :form, :investor_deck_link, :string, :optional, "Link to Investor deck"
    param :form, :investor_deck_file, :string, :optional, "File for Investor deck"
    param_list :form, :current_revenue, :integer, :optional, "Current revenue", ["zero", "two_hundred", "million", "universe"]
    param :form, :current_stage_description, :string, :optional, "Current stage description"
    param :form, :primary_market, :string, :optional, "Primary market"
    param :form, :target_market, :string, :optional, "Target market"
    param_list :form, :target_revenue, :integer, :optional, "Target revenue", ["hundred", "five_hundred", "one_million", "more"]
    param :form, :is_cross_border_expantion, :boolean, :optional, ""
    param :form, :is_consumer_connect, :boolean, :optional, ""
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :ok
    response :unauthorized
    response :not_found
    response :forbidden
    response :unprocessable_entity
    response :bad_request
  end
  def update
    unless Company.stage_of_fundings[params[:stage_of_funding]]
      render json: {stage_of_funding: ["isn't valid"]}, status: :unprocessable_entity and return
    end

    if params[:team_members]
      unless params[:team_members].kind_of?(Array)
        render status: :bad_request and return
      end
    end

    set_company_image
    set_company_team_members
    if @team_member and not @team_member.errors.empty?
      render json: @team_member.errors, status: :unprocessable_entity and return
    end

    if @company.update(update_company_params)
      render json: @company, my: true, status: :ok
    else
      render json: @company.errors, status: :unprocessable_entity
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

    def check_company_ownership
      unless @company.user_id == @user.id
        render json: {errors: :WRONG_COMPANY_ID}, status: :forbidden and return
      end
    end

    def set_company_image
      if params[:image]
        if @company.company_image
          @company.company_image.destroy
        end

        image = CompanyImage.new(base64: params[:image], company_id: @company.id)
        image.save
      end
    end

    def set_company_team_members
      if params[:team_members]
        ActiveRecord::Base.transaction do
          @company.company_team_members.clear
          params[:team_members].each do |team_member|
            @team_member = CompanyTeamMember.new(
              team_member_name: team_member["team_member_name"],
              c_level: CompanyTeamMember.c_levels[team_member["c_level"]],
              company_id: @company.id
            )

            if @team_member.save
              @company.company_team_members << @team_member
              @company.save
            else
              raise ActiveRecord::Rollback
            end
          end
        end
      end
    end

    def check_company_exists
      if @user.company
        render json: {errors: :ALREADY_HAVE_COMPANY}, status: :forbidden and return
      end
    end

    def update_company_params
      params.permit(:website, :description, :contact_email, :stage_of_funding,
                    :investment_amount, :equality_amount, :is_interested_in_access, :is_interested_in_insights,
                    :is_interested_in_capital, :is_interested_in_marketplace, :markets, :founded_in,
                    :is_revenue_consumer, :is_revenue_wholesale, :is_revenue_other, :investor_deck_link,
                    :investor_deck_file, :current_revenue, :current_stage_description, :primary_market,
                    :target_market, :target_revenue, :is_cross_border_expantion, :is_consumer_connect)
    end
end

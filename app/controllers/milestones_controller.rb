class MilestonesController < ApplicationController
  before_action :authorize_startup
  before_action :set_company
  before_action :set_milestone, only: [:show, :update]
  before_action :check_milestone, only: [:show,  :update]
  before_action :check_milestone_done, only: [:update]
  before_action :check_date, only: [:create, :update]
  swagger_controller :milestones, "Company milestones"

  # GET /users/1/companies/1/milestones
  swagger_api :index do
    summary "Retrieve my milestones"
    param :path, :user_id, :integer, :required, "User id"
    param :path, :company_id, :integer, :required, "Company id"
    param :query, :limit, :integer, :optional, "Limit"
    param :query, :offset, :integer, :optional, "Offset"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :ok
    response :unauthorized
    response :not_found
    response :forbidden
  end
  def index
    @milestones = @company.milestones.all

    render json: {
      count: @milestones.count,
      items: @milestones.limit(params[:limit]).offset(params[:offset]).order(:finish_date)
    }, status: :ok
  end

  # GET /users/1/companies/1/milestones/1
  swagger_api :show do
    summary "Retrieve my milestone info"
    param :path, :user_id, :integer, :required, "User id"
    param :path, :company_id, :integer, :required, "Company id"
    param :path, :id, :integer, :required, "Milestone id"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :ok
    response :unauthorized
    response :not_found
    response :forbidden
  end
  def show
    render json: @milestone, status: :ok
  end

  # POST /users/1/companies/1/milestones
  swagger_api :create do
    summary "Create milestone"
    param :path, :user_id, :integer, :required, "User id"
    param :path, :company_id, :integer, :required, "Company id"
    param :form, :title, :string, :required, "Milestone title"
    param :form, :finish_date, :string, :required, "Milestone finish date"
    param :form, :description, :string, :optional, "Milestone description"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :created
    response :unauthorized
    response :not_found
    response :forbidden
  end
  def create
    @milestone = Milestone.new(create_milestone_params)
    @milestone.company_id = @company.id

    if @milestone.save
      render json: @milestone, status: :created
    else
      render json: @milestone.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /users/1/companies/1/milestones/1
  swagger_api :update do
    summary "Create milestone"
    param :path, :user_id, :integer, :required, "User id"
    param :path, :company_id, :integer, :required, "Company id"
    param :form, :title, :string, :optional, "Milestone title"
    param :form, :finish_date, :string, :optional, "Milestone finish date"
    param :form, :description, :string, :optional, "Milestone description"
    param :form, :completeness, :string, :optional, "Milestone completeness"
    param :form, :is_done, :string, :optional, "Mark milestone done"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :ok
    response :unauthorized
    response :not_found
    response :forbidden
  end
  def update
    if @milestone.update(milestone_params)
      render json: @milestone
    else
      render json: @milestone.errors, status: :unprocessable_entity
    end
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

    def set_milestone
      begin
        @milestone = Milestone.find(params[:id])
      rescue
        render status: :not_found and return
      end
    end

    def check_milestone
      if @company.id != @milestone.company_id
        render json: {errors: :ITEM_NOT_BELONG_TO_COMPANY}, status: :forbidden and return
      end
    end

    def check_date
      if params[:finish_date] and DateTime.parse(params[:finish_date]).to_date < DateTime.now.to_date
        render json: {finish_date: ["isn't valid"]}, status: :unprocessable_entity and return
      end
    end

    def check_milestone_done
      if @milestone.is_done == true
        render json: {errors: :MILESTONE_ALREADY_FINISHED}, status: :forbidden and return
      end
    end

    def create_milestone_params
      params.permit(:title, :description, :finish_date)
    end

    def milestone_params
      params.permit(:title, :description, :finish_date, :completeness, :is_done)
    end
end

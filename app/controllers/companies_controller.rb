class CompaniesController < ApplicationController
  before_action :authorize_startup, only: [:my, :my_image, :create, :update, :destroy]
  before_action :set_company, only: [:show, :image, :my_image, :update, :destroy]
  before_action :set_my_company, only: [:my]
  before_action :check_company_ownership, only: [:my_image, :update, :destroy]
  before_action :check_company_exists, only: [:create]
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
    @companies = Company.all

    render json: {
      count: @companies.count,
      items: @companies.limit(params[:limit]).offset(params[:offset])
    }, list: true, status: :ok
  end

  # GET /companies/1
  swagger_api :show do
    summary "Retrieve company info"
    param :path, :id, :integer, :required, "Company id"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :ok
    response :unauthorized
    response :not_found
  end
  def show
    render json: @company, status: :ok
  end

  # GET /companies/1
  swagger_api :image do
    summary "Get company image"
    param :path, :id, :integer, :required, "Company id"
    param :query, :width, :integer, :optional, "Width to crop"
    param :query, :height, :integer, :optional, "Height to crop"
    param :header, 'Authorization', :string, :required, 'Authentication token'
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
      resized = ResizedImage.find_by(image_id: @image.id, width: params[:width], height: params[:height])
      unless resized
        resized = ImageHelper.resize_company_image(@image.id, @image.base64, params[:width], params[:height])
      end

      @image = resized
    end

    send_data Base64.decode64(@image.base64), :type => 'image/png', :disposition => 'inline'
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
      resized = ResizedImage.find_by(image_id: @image.id, width: params[:width], height: params[:height])
      unless resized
        resized = ImageHelper.resize_company_image(@image.id, @image.base64, params[:width], params[:height])
      end

      @image = resized
    end

    send_data Base64.decode64(@image.base64), :type => 'image/png', :disposition => 'inline'
  end

  # GET /users/1/companies/my
  swagger_api :my do
    summary "Retrieve my company info"
    param :path, :user_id, :integer, :required, "Startup user id"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :ok
    response :forbidden
    response :unauthorized
    response :not_found
  end
  def my
    render json: @company, status: :ok
  end

  # POST /users/1/companies
  swagger_api :create do
    summary "Create company"
    param :path, :user_id, :integer, :required, "Startup user id"
    param :form, :name, :string, :required, "Company name"
    param :form, :website, :string, :required, "Company website"
    param :form, :description, :string, :optional, "Company description"
    param :form, :contact_email, :string, :optional, "Company contact email"
    param :form, :image, :string, :optional, "Company logo"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :created
    response :unauthorized
    response :unprocessable_entity
  end
  def create
    Company.transaction do
      @company = Company.new(company_params)
      @company.user_id = @user.id

      if @company.save
        set_company_image
        render json: @company, status: :created
      else
        render json: @company.errors, status: :unprocessable_entity
      end
    end
  rescue
    render json: {errors: :FAILED_SAVE_COMPANY}, status: :unprocessable_entity
  end

  # PATCH/PUT /users/1/companies/1
  swagger_api :update do
    summary "Update company info"
    param :path, :user_id, :integer, :required, "Startup user id"
    param :path, :id, :integer, :required, "Company id"
    param :form, :name, :string, :optional, "Company name"
    param :form, :website, :string, :optional, "Company website"
    param :form, :description, :string, :optional, "Company description"
    param :form, :contact_email, :string, :optional, "Company contact email"
    param :form, :image, :string, :optional, "Company logo"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :ok
    response :unauthorized
    response :not_found
    response :forbidden
    response :unprocessable_entity
  end
  def update
    remove_image
    if @company.update(company_params)
      set_company_image
      render json: @company, status: :ok
    else
      render json: @company.errors, status: :unprocessable_entity
    end
  end

  # DELETE /users/1/companies/1
  swagger_api :destroy do
    summary "Delete company"
    param :path, :user_id, :integer, :required, "Startup user id"
    param :path, :id, :integer, :required, "Company id"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :ok
    response :unauthorized
    response :not_found
    response :forbidden
  end
  def destroy
    @company.destroy

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
        @company = Company.find(params[:id])
      rescue
        render status: :not_found and return
      end
    end

    def set_my_company
      @company = @user.company

      unless @company
        render status: :not_found and return
      end
    end

    def check_company_ownership
      unless @company.user_id == @user.id
        render json: {errors: :WRONG_COMPANY_ID}, status: :forbidden and return
      end
    end

    def remove_image
      if @company.company_image and params[:image]
        @company.company_image.destroy
      end
    end

    def set_company_image
      if params[:image]
        image = CompanyImage.new(base64: params[:image], company_id: @company.id)
        image.save
      end
    end

    def check_company_exists
      if @user.company
        render json: {errors: :ALREADY_HAVE_COMPANY}, status: :forbidden and return
      end
    end

    def company_params
      params.permit(:name, :website, :description, :contact_email)
    end
end

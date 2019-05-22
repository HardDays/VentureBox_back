class CompanyItemsController < ApplicationController
  before_action :authorize_user, except: [:index, :show, :item_image]
  before_action :set_company, except: [:index, :show, :item_image]
  before_action :set_company_item, only: [:show, :item_image, :my_item, :update, :destroy]
  before_action :check_company_item, only: [:my_item, :update, :destroy]
  swagger_controller :company_items, "Company items"

  # GET /company_items
  swagger_api :index do
    summary "Retrieve company items"
    param :query, :limit, :integer, :optional, "Limit"
    param :query, :offset, :integer, :optional, "Offset"
    response :ok
  end
  def index
    @company_items = CompanyItem.all

    render json: {
      count: @company_items.count,
      items: @company_items.limit(params[:limit]).offset(params[:offset])
    }, status: :ok
  end

  # GET /company_items/1
  swagger_api :show do
    summary "Retrieve company item info"
    param :path, :id, :integer, :required, "Company item id"
    response :ok
    response :not_found
  end
  def show
    render json: @company_item, status: :ok
  end

  # GET /company_items/1/image
  swagger_api :item_image do
    summary "Retrieve company item image"
    param :path, :id, :integer, :required, "Company item id"
    response :ok
    response :not_found
  end
  def item_image
    @image = @company_item.image
    unless @image
      render json: {errors: :ITEM_NOT_FOUND}, status: :not_found and return
    end

    send_data Base64.decode64(@image.base64), :type => 'image/png', :disposition => 'inline'
  end

  # GET /users/1/companies/1/company_items
  swagger_api :my_items do
    summary "Retrieve my company items"
    param :path, :user_id, :integer, :required, "User id"
    param :path, :company_id, :integer, :required, "Company id"
    param :query, :limit, :integer, :optional, "Limit"
    param :query, :offset, :integer, :optional, "Offset"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :ok
    response :unauthorized
    response :forbidden
  end
  def my_items
    @company_items = @company.company_items

    render json: {
      count: @company_items.count,
      items: @company_items.limit(params[:limit]).offset(params[:offset])
    }, status: :ok
  end

  # GET /users/1/companies/1/company_items/1
  swagger_api :my_item do
    summary "Retrieve my company item"
    param :path, :user_id, :integer, :required, "User id"
    param :path, :company_id, :integer, :required, "Company id"
    param :path, :id, :integer, :required, "Item id"
    param :query, :limit, :integer, :optional, "Limit"
    param :query, :offset, :integer, :optional, "Offset"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :ok
    response :not_found
    response :unauthorized
    response :forbidden
  end
  def my_item
    render json: @company_item, status: :ok
  end

  # POST /users/1/companies/1/company_items
  swagger_api :create do
    summary "Create my company item"
    param :path, :user_id, :integer, :required, "User id"
    param :path, :company_id, :integer, :required, "Company id"
    param :form, :image, :string, :optional, "Image base64"
    param :form, :name, :string, :required, "Item name"
    param :form, :price, :integer, :optional, "Item price"
    param :form, :link_to_store, :string, :required, "Link to store"
    param :form, :description, :string, :optional, "Item about"
    param :form, :tags, :string, :optional, "Tags array in [:blockchain, :coding, :real_sector, :product, :fintech]"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :created
    response :unauthorized
    response :forbidden
  end
  def create
    @company_item = CompanyItem.new(company_item_params)
    @company_item.company_id = @company.id

    if @company_item.save
      set_item_tags
      render json: @company_item, status: :created
    else
      render json: @company_item.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /users/1/companies/1/company_items/1
  swagger_api :update do
    summary "Update my company item"
    param :path, :user_id, :integer, :required, "User id"
    param :path, :company_id, :integer, :required, "Company id"
    param :path, :id, :integer, :required, "Item id"
    param :form, :image, :string, :optional, "Image base64"
    param :form, :name, :string, :required, "Item name"
    param :form, :price, :integer, :optional, "Item price"
    param :form, :link_to_store, :string, :required, "Link to store"
    param :form, :description, :string, :optional, "Item about"
    param :form, :tags, :string, :optional, "Tags array in [:blockchain, :coding, :real_sector, :product, :fintech]"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :ok
    response :not_found
    response :unauthorized
    response :forbidden
  end
  def update
    if @company_item.update(company_item_params)
      set_item_tags
      render json: @company_item, status: :ok
    else
      render json: @company_item.errors, status: :unprocessable_entity
    end
  end

  # DELETE /users/1/companies/1/company_items/1
  swagger_api :destroy do
    summary "Update my company item"
    param :path, :user_id, :integer, :required, "User id"
    param :path, :company_id, :integer, :required, "Company id"
    param :path, :id, :integer, :required, "Item id"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :created
    response :not_found
    response :unauthorized
    response :forbidden
  end
  def destroy
    @company_item.destroy

    render status: :ok
  end

  private
    def authorize_user
      @user = AuthorizationHelper.authorize(request)

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

    def set_company_item
      begin
        @company_item = CompanyItem.find(params[:id])
      rescue
        render json: {errors: :COMPANY_ITEM_NOT_FOUND}, status: :not_found and return
      end
    end

    def check_company_item
      if @company.id != @company_item.company_id
        render json: {errors: :ITEM_NOT_BELONG_TO_COMPANY}, status: :forbidden and return
      end
    end

    def set_item_tags
      if params[:tags]
        @company_item.company_item_tags.clear
        params[:tags].each do |tag|
          obj = CompanyItemTag.new(tag: tag)
          obj.save
          @company_item.company_item_tags << obj
        end
        @company_item.save
      end
    end

    def company_item_params
      params.permit(:company_id, :image, :name, :price, :link_to_store, :description)
    end
end

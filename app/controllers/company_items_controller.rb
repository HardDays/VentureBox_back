class CompanyItemsController < ApplicationController
  before_action :authorize_startup, except: [:index, :show, :item_image, :company_items]
  before_action :set_company, only: [:company_items]
  before_action :set_my_company, except: [:index, :show, :item_image, :company_items]
  before_action :set_company_item, only: [:show, :item_image, :my_item, :my_item_image, :update, :destroy]
  before_action :check_company_item, only: [:my_item, :my_item_image,  :update, :destroy]
  swagger_controller :company_items, "Company items"

  # GET /company_items
  swagger_api :index do
    summary "Retrieve company items"
    param :query, :limit, :integer, :optional, "Limit"
    param :query, :offset, :integer, :optional, "Offset"
    param :query, :tags, :string, :optional, "Tags array to search"
    param :query, :text, :string, :optional, "text to search"
    response :ok
  end
  def index
    @company_items = CompanyItem.all
    search_tags
    search_text

    render json: {
      count: @company_items.count,
      items: @company_items.limit(params[:limit]).offset(params[:offset])
    }, status: :ok
  end

  # GET /companies/1/company_items
  swagger_api :company_items do
    summary "Retrieve company items"
    param :path, :id, :integer, :required, "Company id"
    param :query, :limit, :integer, :optional, "Limit"
    param :query, :offset, :integer, :optional, "Offset"
    response :ok
    response :not_found
  end
  def company_items
    @company_items = @company.company_items.all

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
    param :query, :width, :integer, :optional, "Width to crop"
    param :query, :height, :integer, :optional, "Height to crop"
    param :path, :id, :integer, :required, "Company item id"
    response :ok
    response :not_found
  end
  def item_image
    @image = @company_item.company_item_image
    unless @image
      render json: {errors: :ITEM_NOT_FOUND}, status: :not_found and return
    end

    if params[:width] and params[:height]
      resized = ResizedCompanyItemImage.find_by(company_item_image_id: @image.id, width: params[:width], height: params[:height])
      unless resized
        resized = ImageHelper.resize_company_item_image(@image.id, @image.base64, params[:width], params[:height])
      end

      @image = resized
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

  # GET /users/1/companies/1/company_items/1/image
  swagger_api :my_item_image do
    summary "Retrieve company item image"
    param :path, :user_id, :integer, :required, "User id"
    param :path, :company_id, :integer, :required, "Company id"
    param :path, :id, :integer, :required, "Company item id"
    param :query, :width, :integer, :optional, "Width to crop"
    param :query, :height, :integer, :optional, "Height to crop"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :ok
    response :not_found
  end
  def my_item_image
    @image = @company_item.company_item_image
    unless @image
      render json: {errors: :ITEM_NOT_FOUND}, status: :not_found and return
    end

    if params[:width] and params[:height]
      resized = ResizedCompanyItemImage.find_by(company_item_image_id: @image.id, width: params[:width], height: params[:height])
      unless resized
        resized = ImageHelper.resize_company_item_image(@image.id, @image.base64, params[:width], params[:height])
      end

      @image = resized
    end

    send_data Base64.decode64(@image.base64), :type => 'image/png', :disposition => 'inline'
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
    param :form, :tags, :string, :optional, "Tags array in [blockchain, coding, real_sector, product, fintech]"
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
      set_item_image
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
    param :form, :tags, :string, :optional, "Tags array in [blockchain, coding, real_sector, product, fintech]"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :ok
    response :not_found
    response :unauthorized
    response :forbidden
  end
  def update
    remove_image
    if @company_item.update(company_item_params)
      set_item_image
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

    def search_tags
      if params[:tags]
        tags = []
        params[:tags].each do |tag|
          tags.append(CompanyItemTag.tags[tag])
        end

        @company_items = @company_items.joins(:company_item_tags).where(:company_item_tags => {tag: tags})
      end
    end

    def search_text
      if params[:text]
        @company_items = @company_items.where(
          "(company_items.name ILIKE :query) ", query: "%#{params[:text]}%")
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

    def set_item_image
      if params[:image]
        image = CompanyItemImage.new(base64: params[:image], company_item_id: @company_item.id)
        image.save
      end
    end

    def remove_image
      if @company_item.company_item_image and params[:image]
        @company_item.company_item_image.destroy
      end
    end

    def company_item_params
      params.permit(:company_id, :name, :price, :link_to_store, :description)
    end
end

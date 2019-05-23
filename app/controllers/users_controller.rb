class UsersController < ApplicationController
  before_action :authorize_user, only: [:show, :update, :destroy]
  swagger_controller :user, 'User'

  # GET /users/1
  swagger_api :show do
    summary "Retrieve user info"
    param :path, :id, :integer, :required, "User id"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :ok
    response :unauthorized
    response :not_found
  end
  def show
    render json: @user, status: :ok
  end

  # POST /users
  swagger_api :create do
    summary "Create user"
    param :form, :name, :string, :required, "User name"
    param :form, :surname, :string, :required, "User surname"
    param :form, :email, :string, :required, "User email"
    param :form, :phone, :string, :optional, "User phone"
    param :form, :password, :string, :required, "User password"
    param :form, :password_confirmation, :string, :required, "User password confirmation"
    param_list :form, :role, :string, :required, "User role", [:startup, :investor]
    param :form, :goals, :string, :optional, "User goals"
    response :created
    response :unprocessable_entity
  end
  def create
    User.transaction do
      @user = User.new(user_params)

      if @user.save
        token = AuthenticationHelper.process_token(request, @user)

        user = @user.as_json
        user["token"] = token.token
        render json: user, status: :created
      else
        render json: @user.errors, status: :unprocessable_entity
      end
    end
  rescue
    render json: {errors: :FAILED_SAVE_USER}, status: :unprocessable_entity
  end

  # PATCH/PUT /users/1
  swagger_api :update do
    summary "Update user info"
    param :path, :id, :integer, :required, "User id"
    param :form, :old_password, :string, :optional, "User old password"
    param :form, :password, :string, :optional, "User password"
    param :form, :password_confirmation, :string, :optional, "User password confirmation"
    param :form, :turn_email_notifications, :boolean, :optional, "Turn on email notifications"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :ok
    response :unauthorized
    response :forbidden
    response :unprocessable_entity
  end
  def update
    if params[:turn_email_notifications]
      @user.is_email_notifications_available = true
    end

    if @user.update(user_params)
      render json: @user, status: :ok
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # DELETE /users/1
  swagger_api :destroy do
    summary "Update user info"
    param :path, :id, :integer, :required, "User id"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :ok
    response :unauthorized
    response :forbidden
  end
  def destroy
    @user.destroy

    render status: :ok
  end

  private
    def authorize_user
      @user = AuthorizationHelper.authorize(request)

      if @user == nil
        render status: :unauthorized and return
      end

      if @user.id != params[:id].to_i
        render json: {errors: :WRONG_USER_ID}, status: :forbidden and return
      end
    end

    def user_params
      params.permit(:role, :name, :surname, :email, :phone, :password, :password_confirmation, :old_password, :goals)
    end
end

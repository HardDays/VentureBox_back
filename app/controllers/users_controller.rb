class UsersController < ApplicationController
  before_action :authorize_user, only: [:show, :me, :change_general, :change_email, :change_password, :destroy]
  before_action :check_user, only: [:show, :change_general, :change_email, :change_password, :destroy]
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

  # GET /users/1
  swagger_api :me do
    summary "Retrieve my info"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :ok
    response :unauthorized
    response :not_found
  end
  def me
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
    param :form, :goals, :string, :optional, "User goals"
    param_list :form, :role, :string, :required, "User role", ["startup", "investor"]
    param :form, :company_name, :string, :optional, "(required for startup) Company name"
    param :form, :website, :string, :optional, "Company website"
    param :form, :contact_email, :string, :optional, "(required for startup) Company contact email"
    param :form, :image, :string, :optional, "(required for startup) Company logo"
    param :form, :description, :string, :optional, "(required for startup) Company description"
    param_list :form, :stage_of_funding, :string, :optional, "(required for startup) Company stage of funding", ["idea", "pre_seed", "seed", "serial_a", "serial_b", "serial_c"]
    param :form, :investment_amount, :integer, :optional, "Company investment amount"
    param :form, :equality_amount, :integer, :optional, "Company equality amount"
    param :form, :team_members, :string, :optional, "Company team members [{team_member_name: name, c_level: cto}]"
    response :created
    response :unprocessable_entity
  end
  def create
    if params[:role] == "startup"
      if params[:stage_of_funding] and not Company.stage_of_fundings[params[:stage_of_funding]]
        render json: {stage_of_funding: ["isn't valid"]}, status: :unprocessable_entity and return
      end

      if params[:team_members]
        unless params[:team_members].kind_of?(Array)
          render status: :bad_request and return
        end
      end

      unless params[:image]
        render json: {image: ["can't be blank"]}, status: :unprocessable_entity and return
      end
    end

    User.transaction do
      @user = User.new(user_params)

      if @user.save
        if @user.role == "startup"
          @company = Company.new(company_params)
          @company.user_id = @user.id

          if @company.save
            set_company_image
            set_company_team_members

            if @team_member and not @team_member.errors.empty?
              render json: @team_member.errors, status: :unprocessable_entity and return
            end
          else
            @user.destroy
            render json: @company.errors, status: :unprocessable_entity and return
          end
        end

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

  # PATCH/PUT /users/1/change_password
  swagger_api :change_password do
    summary "Update user password"
    param :path, :id, :integer, :required, "User id"
    param :form, :old_password, :string, :required, "User old password"
    param :form, :password, :string, :required, "User password"
    param :form, :password_confirmation, :string, :required, "User password confirmation"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :ok
    response :unauthorized
    response :forbidden
    response :unprocessable_entity
  end
  def change_password
    if @user.update(change_password_params)
      render json: @user, status: :ok
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /users/1/change_email
  swagger_api :change_email do
    summary "Update user email"
    param :path, :id, :integer, :required, "User id"
    param :form, :email, :string, :required, "User new email"
    param :form, :current_email, :string, :required, "User old email"
    param :form, :current_password, :string, :required, "User password"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :ok
    response :unauthorized
    response :forbidden
    response :unprocessable_entity
  end
  def change_email
    if @user.update(change_email_params)
      render json: @user, status: :ok
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /users/1/change_general
  swagger_api :change_general do
    summary "Update user general info"
    param :path, :id, :integer, :required, "User id"
    param :form, :name, :string, :required, "User name"
    param :form, :surname, :string, :required, "User surname"
    param :form, :is_email_notifications_available, :boolean, :optional, "Turn on email notifications"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :ok
    response :unauthorized
    response :forbidden
    response :unprocessable_entity
  end
  def change_general
    if @user.update(change_general_params)
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
    end

    def check_user
      if @user.id != params[:id].to_i
        render json: {errors: :WRONG_USER_ID}, status: :forbidden and return
      end
    end

    def set_company_image
      if params[:image]
        image = CompanyImage.new(base64: params[:image], company_id: @company.id)
        image.save
      end
    end

    def set_company_team_members
      if params[:team_members]
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
            @user.destroy

            @team_member
          end
        end
      end
    end

    def user_params
      params.permit(:role, :name, :surname, :email, :phone, :password, :password_confirmation, :old_password, :goals)
    end

    def company_params
      params.permit(:company_name, :website, :description, :contact_email, :stage_of_funding, :investment_amount, :equality_amount)
    end

    def change_password_params
      params.permit(:password, :password_confirmation, :old_password)
    end

    def change_email_params
      params.permit(:current_password, :email, :current_email)
    end

    def change_general_params
      params.permit(:name, :surname, :is_email_notifications_available)
    end
end

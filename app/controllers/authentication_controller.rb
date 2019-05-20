require 'securerandom'

class AuthenticationController < ApplicationController
  swagger_controller :authentication, "Authentication"

  # POST /auth/forgot_password
  swagger_api :forgot_password do
    summary "Remind password"
    param :form, :email, :string, :required, "Email"
    response :ok
    response :unauthorized
    response :bad_request
  end
  def forgot_password
    @user = User.find_by("LOWER(email) = ?", params[:email].downcase)
    unless @user
      render json: {error: :LOGIN_DOES_NOT_EXIST}, status: :unauthorized and return
    end

    @attempt = ForgotPasswordAttempt.where(
      user_id: @user.id,
      created_at: (Time.zone.now.beginning_of_day..Time.zone.now.end_of_day)
    ).first

    if @attempt
      if @attempt.attempts_count >= 3
        render json: {error: :TOO_MANY_ATTEMPTS}, status: :bad_request and return
      end

      @attempt.attempts_count += 1
      @attempt.save
    else
      @attempt = ForgotPasswordAttempt.new(user_id: @user.id, attempt_count: 1)
      @attempt.save
    end

    password = SecureRandom.hex(4)
    @user.password = password
    begin
      ForgotPasswordMailer.forgot_password_email(params[:email], password).deliver

      @user.save(validate: false)
      render status: :ok
    rescue => ex
      render status: :bad_request
    end
  end


  # POST /auth/login
  swagger_api :login do
    summary "Authorize by email and password"
    param :form, :email, :string, :required, "Email"
    param :form, :password, :password, :required, "Password"
    response :ok
    response :unprocessable_entity
    response :not_found
    response :unauthorized
  end
  def login
    @password = User.encrypt_password(params[:password])

    if params[:email]
      @user = User.find_by("LOWER(email) = ?", params[:email].downcase)
    else
      render json: {errors: :EMAIL_REQUIRED}, status: :unprocessable_entity and return
    end

    unless @user
      render status: :not_found and return
    end

    if @user.password != @password
      render status: :forbidden and return
    end

    token = AuthenticationHelper.process_token(request, @user)
    render json: {token: token.token}, status: :ok
  end

  # POST /auth/logout
  swagger_api :logout do
    summary "Logout"
    param :header, 'Authorization', :string, :required, 'Authentication token'
    response :ok
    response :unauthorized
  end
  def logout
    @token = Token.find_by(token: request.headers['Authorization'])

    if @token
      @token.destroy
      render status: :ok
    else
      render json: {errors: :TOKEN_NOT_FOUND}, status: :unauthorized
    end
  end
end

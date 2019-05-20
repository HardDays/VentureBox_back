module AuthorizationHelper

  def self.authorize(request)
    @tokenstr = request.headers['Authorization']
    @token = Token.find_by token: @tokenstr
    return @token if not @token

    @token.user
  end

  def self.authorize_startup(request)
    @user = self.authorize(request)

    unless @user.role == 'startup'
      return nil
    end

    @user
  end
end

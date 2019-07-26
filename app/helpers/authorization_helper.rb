module AuthorizationHelper

  def self.authorize(request)
    @tokenstr = request.headers['Authorization']
    @token = Token.find_by token: @tokenstr
    return @token if not @token

    unless @token.user && @token.user.status == "approved"
      return nil
    end

    @token.user
  end

  def self.authorize_startup(request)
    @user = self.authorize(request)

    unless @user
      return nil
    end

    unless @user.role == 'startup'
      return nil
    end

    @user
  end

  def self.authorize_investor(request)
    @user = self.authorize(request)

    unless @user
      return nil
    end

    unless @user.role == 'investor'
      return nil
    end

    @user
  end
end

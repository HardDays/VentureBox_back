module AuthorizationHelper

  def self.authorize(request)
    @tokenstr = request.headers['Authorization']
    @token = Token.find_by token: @tokenstr
    return @token if not @token

    return @token.user
  end
end

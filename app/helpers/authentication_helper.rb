module AuthenticationHelper
  SALT = ENV.fetch("TOKEN_SALT")

  def self.process_token(request, user)
    if request.ip and request.user_agent
      token_str = Digest::SHA256.hexdigest(user.id.to_s + request.ip + request.user_agent + SALT)
    else
      token_str = SecureRandom.hex
    end

    token = user.tokens.find{|s| s.token == token_str}
    token.destroy if token

    token = Token.new(user_id: user.id, token: token_str)
    token.save

    return token
  end
end

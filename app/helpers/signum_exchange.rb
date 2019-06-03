class SignumExchange
  include HTTParty
  base_uri 'scout.tenoris.net'

  def get_index(company_domain)
    result = self.class.get("/index-output.php?domain=#{company_domain}").body

    result = JSON.parse result
    result["index"]
  end
end

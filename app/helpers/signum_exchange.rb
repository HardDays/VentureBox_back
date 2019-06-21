require "erb"
include ERB::Util

class SignumExchange
  include HTTParty
  base_uri 'scout.tenoris.net'

  def get_index(company_domain)
    company_domain = url_encode(company_domain)
    result = self.class.get("/index-output.php?domain=#{company_domain}")

    unless result.code == 200
      return 0
    end

    result = JSON.parse result.body
    result["index"]
  end
end

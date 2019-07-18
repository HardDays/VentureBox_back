class EspoExchange
  include HTTParty
  base_uri 'http://ec2-18-222-201-141.us-east-2.compute.amazonaws.com:8080/api/v1'

  def self.create_user(login, password, first_name, last_name)
    response = self.class.post(
      '/User',
      headers: {
        'Content-Type': 'application/json',
        'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/52.0.2743 Safari/537.36'
      },
      basic_auth: {
        username: Rails.configuration.crm_login,
        password: Rails.configuration.crm_password
      },
      body: {
        'userName': login,
        'firstName': first_name,
        'lastName': last_name,
        'password': password,
        'passwordConfirm': password
      }.to_json
    )

    print response.body
    return response.code == 200
  end

  def self.create_order

  end

end

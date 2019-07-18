class EspoExchange
  include HTTParty
  base_uri 'http://ec2-18-222-201-141.us-east-2.compute.amazonaws.com:8080/api/v1'

  def create_user(login, password, first_name, last_name)
    response = self.class.get(
      '/Role',
      headers: {
        'Content-Type': 'application/json',
        'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/52.0.2743 Safari/537.36'
      },
      basic_auth: {
        username: Rails.configuration.crm_login,
        password: Rails.configuration.crm_password
      }
    )
    unless response.code == 200
      return false
    end

    roles = JSON.parse response.body
    role_id = 0
    roles["list"].each do |role|
      if role["name"] == "default"
        role_id = role["id"]
      end
    end

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
        'passwordConfirm': password,
        'rolesIds': [role_id]
      }.to_json
    )

    if response.code == 200
      data = JSON.parse response.body
      data["id"]
    else
      nil
    end
  end

  def create_order(name, price, creation_date, user_id)
    response = self.class.post(
      '/Opportunity',
      headers: {
        'Content-Type': 'application/json',
        'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/52.0.2743 Safari/537.36'
      },
      basic_auth: {
        username: Rails.configuration.crm_login,
        password: Rails.configuration.crm_password
      },
      body: {
        "name": name,
        "amount": price,
        "stage": "Closed Won",
        "probability": 100,
        "createdAt": creation_date.strftime("%Y-%m-%d %H:%M:%S"),
        "closeDate": creation_date.strftime("%Y-%m-%d"),
        "assignedUserId": user_id,
      }.to_json
    )

    response.code == 200
  end

end

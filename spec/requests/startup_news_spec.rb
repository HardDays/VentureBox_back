require 'rails_helper'

RSpec.describe "StartupNews", type: :request do
  let(:password) { "123123" }
  let!(:user)  { create(:user, password: password, password_confirmation: password, role: :startup) }
  let!(:company) { create(:company, user_id: user.id) }

  let!(:startup_news) { create(:startup_news, company_id: company.id) }
  let!(:startup_news2) { create(:startup_news, company_id: company.id) }
  let!(:startup_news3) { create(:startup_news, company_id: company.id) }

  let!(:user2)  { create(:user, password: password, password_confirmation: password, role: :startup) }
  let!(:company2) { create(:company, user_id: user2.id) }
  let!(:startup_news4) { create(:startup_news, company_id: company2.id) }

  let!(:investor) { create(:user, password: password, password_confirmation: password, role: :investor )}

  let(:valid_attributes) { { text: "text" } }
  let(:valid_attributes1) { { text: "text1" } }

  # Test suite for GET /startup_news
  describe 'GET /startup_news' do
    context 'when simply get' do
      before do
        post "/auth/login", params: {email: investor.email, password: password}
        token = json['token']

        get "/startup_news", headers: {'Authorization': token}
      end

      it "return all items" do
        expect(json).not_to be_empty
        expect(json['count']).to eq(4)
        expect(json['items'].size).to eq(4)
      end

      it "return all item info" do
        expect(json['items'][0]["id"]).to be_a_kind_of(Integer)
        expect(json['items'][0]["text"]).to be_a_kind_of(String)
        expect(json['items'][0]["company_id"]).to be_a_kind_of(Integer)
        expect(json['items'][0]["company_name"]).to be_a_kind_of(String)
        expect(json['items'][0]["created_at"]).to be_a_kind_of(String)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when use limit' do
      before do
        post "/auth/login", params: {email: investor.email, password: password}
        token = json['token']

        get "/startup_news", params: {limit: 2}, headers: {'Authorization': token}
      end

      it "returns 2 items" do
        expect(json).not_to be_empty
        expect(json['count']).to eq(4)
        expect(json['items'].size).to eq(2)
      end

      it "return all item info" do
        expect(json['items'][0]["id"]).to be_a_kind_of(Integer)
        expect(json['items'][0]["text"]).to be_a_kind_of(String)
        expect(json['items'][0]["company_id"]).to be_a_kind_of(Integer)
        expect(json['items'][0]["company_name"]).to be_a_kind_of(String)
        expect(json['items'][0]["created_at"]).to be_a_kind_of(String)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when use offset' do
      before do
        post "/auth/login", params: {email: investor.email, password: password}
        token = json['token']

        get "/startup_news", params: {offset: 2}, headers: {'Authorization': token}
      end

      it "returns response with offset" do
        expect(json).not_to be_empty
        expect(json['count']).to eq(4)
        expect(json['items'].size).to eq(2)
      end

      it "return all item info" do
        expect(json['items'][0]["id"]).to be_a_kind_of(Integer)
        expect(json['items'][0]["text"]).to be_a_kind_of(String)
        expect(json['items'][0]["company_id"]).to be_a_kind_of(Integer)
        expect(json['items'][0]["company_name"]).to be_a_kind_of(String)
        expect(json['items'][0]["created_at"]).to be_a_kind_of(String)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when not authorized' do
      before do
        get "/startup_news"
      end

      it 'returns status code 401' do
        expect(response).to have_http_status(401)
      end

      it 'returns a not found message' do
        expect(response.body).to match("")
      end
    end
  end

  # Test suite for GET /startup_news/1
  describe 'GET /startup_news/1' do
    context 'when the record exists' do
      before do
        post "/auth/login", params: {email: investor.email, password: password}
        token = json['token']

        get "/startup_news/#{startup_news.id}", headers: {'Authorization': token}
      end

      it 'returns the company' do
        expect(json).not_to be_empty
        expect(json['id']).to eq(startup_news.id)
      end

      it "return all company info" do
        expect(json["id"]).to eq(startup_news.id)
        expect(json["company_name"]).to eq(startup_news.company.company_name)
        expect(json["company_id"]).to eq(startup_news.company_id)
        expect(json["text"]).to eq(startup_news.text)
        expect(json["created_at"]).to be_kind_of(String)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when the record does not exist' do
      let(:startup_news_id) { 0 }

      before do
        post "/auth/login", params: {email: investor.email, password: password}
        token = json['token']

        get "/startup_news/#{startup_news_id}", headers: {'Authorization': token}
      end

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a not found message' do
        expect(response.body).to match("")
      end
    end

    context 'when not authorized' do
      before do
        get "/startup_news/#{startup_news.id}"
      end

      it 'returns status code 401' do
        expect(response).to have_http_status(401)
      end

      it 'returns a not found message' do
        expect(response.body).to match("")
      end
    end
  end

  # Test suite for GET /users/1/companies/1/startup_news
  describe 'GET /users/1/companies/1/startup_news' do
    context 'when simply get' do
      before do
        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        get "/users/#{user.id}/companies/#{company.id}/startup_news", headers: { 'Authorization': token }
      end

      it "return all items" do
        expect(json).not_to be_empty
        expect(json['count']).to eq(3)
        expect(json['items'].size).to eq(3)
      end

      it "return all item info" do
        expect(json['items'][0]["id"]).to be_a_kind_of(Integer)
        expect(json['items'][0]["company_id"]).to be_a_kind_of(Integer)
        expect(json['items'][0]["company_name"]).to be_a_kind_of(String)
        expect(json['items'][0]["text"]).to be_a_kind_of(String)
        expect(json['items'][0]["created_at"]).to be_a_kind_of(String)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when use limit' do
      before do
        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        get "/users/#{user.id}/companies/#{company.id}/startup_news", params: {limit: 2}, headers: { 'Authorization': token }
      end

      it "returns 2 items" do
        expect(json).not_to be_empty
        expect(json['count']).to eq(3)
        expect(json['items'].size).to eq(2)
      end

      it "return all item info" do
        expect(json['items'][0]["id"]).to be_a_kind_of(Integer)
        expect(json['items'][0]["company_id"]).to be_a_kind_of(Integer)
        expect(json['items'][0]["company_name"]).to be_a_kind_of(String)
        expect(json['items'][0]["text"]).to be_a_kind_of(String)
        expect(json['items'][0]["created_at"]).to be_a_kind_of(String)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when use offset' do
      before do
        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        get "/users/#{user.id}/companies/#{company.id}/startup_news", params: {offset: 2}, headers: { 'Authorization': token }
      end

      it "returns response with offset" do
        expect(json).not_to be_empty
        expect(json['count']).to eq(3)
        expect(json['items'].size).to eq(1)
      end

      it "return all item info" do
        expect(json['items'][0]["id"]).to be_a_kind_of(Integer)
        expect(json['items'][0]["company_id"]).to be_a_kind_of(Integer)
        expect(json['items'][0]["company_name"]).to be_a_kind_of(String)
        expect(json['items'][0]["text"]).to be_a_kind_of(String)
        expect(json['items'][0]["created_at"]).to be_a_kind_of(String)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when i am not startup' do
      before do
        post "/auth/login", params: {email: investor.email, password: password}
        token = json['token']

        get "/users/#{user.id}/companies/#{company.id}/startup_news/", headers: {'Authorization': token}
      end

      it "returns nothing" do
        expect(response.body).to match("")
      end

      it 'returns status code 401' do
        expect(response).to have_http_status(401)
      end
    end

    context 'when not my company' do
      before do
        post "/auth/login", params: {email: user2.email, password: password}
        token = json['token']

        get "/users/#{user2.id}/companies/#{company.id}/startup_news/", headers: {'Authorization': token}
      end

      it "returns nothing" do
        expect(response.body).to match("")
      end

      it 'returns status code 403' do
        expect(response).to have_http_status(403)
      end
    end

    context 'when not authorized' do
      before { get "/users/#{user.id}/companies/#{company.id}/startup_news/" }

      it 'returns status code 401' do
        expect(response).to have_http_status(401)
      end

      it 'returns a not found message' do
        expect(response.body).to match("")
      end
    end
  end

  # Test suite for GET /users/1/companies/1/startup_news/1
  describe 'GET /users/1/companies/1/startup_news/1' do
    context 'when the record exists' do
      before do
        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        get "/users/#{user.id}/companies/#{company.id}/startup_news/#{startup_news.id}", headers: { 'Authorization': token }
      end

      it 'returns the company' do
        expect(json).not_to be_empty
        expect(json['id']).to eq(startup_news.id)
      end

      it "return all company info" do
        expect(json["id"]).to eq(startup_news.id)
        expect(json["company_name"]).to eq(startup_news.company.company_name)
        expect(json["company_id"]).to eq(startup_news.company_id)
        expect(json["text"]).to eq(startup_news.text)
        expect(json["created_at"]).to be_kind_of(String)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when the record does not exist' do
      let(:startup_news_id) { 0 }

      before do
        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        get "/users/#{user.id}/companies/#{company.id}/startup_news/#{startup_news_id}", headers: { 'Authorization': token }
      end

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a not found message' do
        expect(response.body).to match("")
      end
    end

    context 'when i am not startup' do
      before do
        post "/auth/login", params: {email: investor.email, password: password}
        token = json['token']

        get "/users/#{user.id}/companies/#{company.id}/startup_news/#{startup_news.id}", headers: {'Authorization': token}
      end

      it "returns nothing" do
        expect(response.body).to match("")
      end

      it 'returns status code 401' do
        expect(response).to have_http_status(401)
      end
    end

    context 'when not my company' do
      before do
        post "/auth/login", params: {email: user2.email, password: password}
        token = json['token']

        get "/users/#{user2.id}/companies/#{company.id}/startup_news/#{startup_news.id}", headers: {'Authorization': token}
      end

      it "returns nothing" do
        expect(response.body).to match("")
      end

      it 'returns status code 403' do
        expect(response).to have_http_status(403)
      end
    end

    context 'when not my companys item' do
      before do
        post "/auth/login", params: {email: user.email, password: password}
        token = json['token']

        get "/users/#{user.id}/companies/#{company.id}/startup_news/#{startup_news4.id}", headers: {'Authorization': token}
      end

      it "returns nothing" do
        expect(response.body).to match("")
      end

      it 'returns status code 403' do
        expect(response).to have_http_status(403)
      end
    end

    context 'when not authorized' do
      before { get "/users/#{user.id}/companies/#{company.id}/startup_news/#{startup_news.id}" }

      it 'returns status code 401' do
        expect(response).to have_http_status(401)
      end

      it 'returns a not found message' do
        expect(response.body).to match("")
      end
    end
  end

  # Test suite for POST /users/1/companies/1/startup_news
  describe 'POST /users/1/companies/1/startup_news' do
    context 'when the request is valid' do
      before do
        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        post "/users/#{user.id}/companies/#{company.id}/startup_news", params: valid_attributes, headers: { 'Authorization': token }
      end

      it 'creates a company item' do
        expect(json['text']).to eq('text')
        expect(json['company_id']).to eq(company.id)
        expect(json['company_name']).to eq(company.company_name)
        expect(json["created_at"]).to be_a_kind_of(String)
      end

      it 'returns status code 201' do
        expect(response).to have_http_status(201)
      end
    end

    context 'when the request without name' do
      before do
        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        post "/users/#{user.id}/companies/#{company.id}/startup_news", params: {}, headers: { 'Authorization': token }
      end

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a validation failure message' do
        expect(response.body)
          .to match("{\"text\":[\"can't be blank\"]}")
      end
    end

    context 'when i am not startup' do
      before do
        post "/auth/login", params: { email: investor.email, password: password}
        token = json['token']

        post "/users/#{user.id}/companies/#{company.id}/startup_news", params: valid_attributes, headers: { 'Authorization': token }
      end

      it 'returns status code 401' do
        expect(response).to have_http_status(401)
      end

      it 'response is empty' do
        expect(response.body).to match("")
      end
    end

    context 'when not my company' do
      before do
        post "/auth/login", params: {email: user2.email, password: password}
        token = json['token']

        post "/users/#{user2.id}/companies/#{company.id}/startup_news", headers: {'Authorization': token}
      end

      it "returns nothing" do
        expect(response.body).to match("")
      end

      it 'returns status code 403' do
        expect(response).to have_http_status(403)
      end
    end

    context 'when the user unauthorized' do
      before do
        post "/users/#{user.id}/companies/#{company.id}/startup_news", params: valid_attributes
      end

      it 'returns status code 401' do
        expect(response).to have_http_status(401)
      end

      it 'response is empty' do
        expect(response.body).to match("")
      end
    end
  end

  # Test suite for DELETE /users/1/companies/1/startup_news/1
  describe 'DELETE /users/1/companies/1/startup_news/1' do
    context 'when the request is valid' do
      before do
        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        delete "/users/#{user.id}/companies/#{company.id}/startup_news/#{startup_news.id}", headers: { 'Authorization': token }
      end

      it 'response is empty' do
        expect(response.body).to match("")
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when does not exists' do
      let(:startup_news_id) { 0 }

      before do
        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        delete "/users/#{user.id}/companies/#{company.id}/startup_news/#{startup_news_id}", headers: { 'Authorization': token }
      end

      it 'response is empty' do
        expect(response.body).to match("")
      end

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end
    end

    context 'when not my company' do
      before do
        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        delete "/users/#{user.id}/companies/#{company2.id}/startup_news/#{startup_news.id}", headers: { 'Authorization': token }
      end

      it 'returns status code 403' do
        expect(response).to have_http_status(403)
      end

      it 'response is empty' do
        expect(response.body).to match("")
      end
    end

    context 'when not my item' do
      before do
        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        delete "/users/#{user.id}/companies/#{company.id}/startup_news/#{startup_news4.id}", headers: { 'Authorization': token }
      end

      it 'returns status code 403' do
        expect(response).to have_http_status(403)
      end

      it 'response is empty' do
        expect(response.body).to match("")
      end
    end

    context 'when i am not startup' do
      before do
        post "/auth/login", params: { email: investor.email, password: password}
        token = json['token']

        delete "/users/#{user.id}/companies/#{company.id}/startup_news/#{startup_news.id}", headers: { 'Authorization': token }
      end

      it 'returns status code 401' do
        expect(response).to have_http_status(401)
      end

      it 'response is empty' do
        expect(response.body).to match("")
      end
    end

    context 'when the user unauthorized' do
      before do
        delete "/users/#{user.id}/companies/#{company.id}/startup_news/#{startup_news.id}"
      end

      it 'returns status code 401' do
        expect(response).to have_http_status(401)
      end

      it 'response is empty' do
        expect(response.body).to match("")
      end
    end
  end
end

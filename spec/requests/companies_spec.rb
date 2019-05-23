require 'rails_helper'

RSpec.describe "Companies", type: :request do
  let(:password) { "123123" }
  let!(:user)  { create(:user, password: password, role: :startup) }
  let!(:company) { create(:company, user_id: user.id) }

  let!(:user2)  { create(:user, password: password, role: :startup) }
  let!(:company2) { create(:company, user_id: user2.id) }

  let!(:user3)  { create(:user, password: password, role: :startup) }
  let!(:company3) { create(:company, user_id: user3.id) }

  let!(:investor) { create(:user, password: password, role: :investor )}
  let!(:new_user) { create(:user, password: password, role: :startup)}

  let(:valid_attributes) { { name: "name", website: "domain.com", description: "description" } }
  let(:valid_attributes1) { { name: "name1", website: "domain1.com", description: "description1" } }
  let(:without_name) { { website: "domain.com", description: "description" } }
  let(:without_website) { { name: "name", description: "description" } }

  # Test suite for GET /companies
  describe 'GET /companies' do
    context 'when simply get' do
      before do
        post "/auth/login", params: {email: investor.email, password: password}
        token = json['token']

        get "/companies", headers: {'Authorization': token}
      end

      it "return all companies" do
        expect(json).not_to be_empty
        expect(json['count']).to eq(3)
        expect(json['items'].size).to eq(3)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when use limit' do
      before do
        post "/auth/login", params: {email: investor.email, password: password}
        token = json['token']

        get "/companies", params: {limit: 2}, headers: {'Authorization': token}
      end

      it "returns 2 entities" do
        expect(json).not_to be_empty
        expect(json['count']).to eq(3)
        expect(json['items'].size).to eq(2)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when use offset' do
      before do
        post "/auth/login", params: {email: investor.email, password: password}
        token = json['token']

        get "/companies", params: {offset: 2}, headers: {'Authorization': token}
      end

      it "returns response with offset" do
        expect(json).not_to be_empty
        expect(json['count']).to eq(3)
        expect(json['items'].size).to eq(1)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when i am not investor' do
      before do
        post "/auth/login", params: {email: user.email, password: password}
        token = json['token']

        get "/companies", params: {offset: 2}, headers: {'Authorization': token}
      end

      it "returns nothing" do
        expect(response.body).to match("")
      end

      it 'returns status code 401' do
        expect(response).to have_http_status(401)
      end
    end

    context 'when not authorized' do
      before do
        get "/companies"
      end

      it "returns nothing" do
        expect(response.body).to match("")
      end

      it 'returns status code 401' do
        expect(response).to have_http_status(401)
      end
    end
  end

  # Test suite for GET /companies/1
  describe 'GET /companies/1' do
    context 'when the record exists' do
      before do
        post "/auth/login", params: { email: investor.email, password: password}
        token = json['token']

        get "/companies/#{company.id}", headers: { 'Authorization': token }
      end

      it 'returns the company' do
        expect(json).not_to be_empty
        expect(json['id']).to eq(company.id)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when the record does not exist' do
      let(:company_id) { 0 }

      before do
        post "/auth/login", params: { email: investor.email, password: password}
        token = json['token']

        get "/companies/#{company_id}", headers: { 'Authorization': token }
      end

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a not found message' do
        expect(response.body).to match("")
      end
    end

    context 'when i am not investor' do
      before do
        post "/auth/login", params: {email: user.email, password: password}
        token = json['token']

        get "/companies/#{company.id}", headers: {'Authorization': token}
      end

      it "returns nothing" do
        expect(response.body).to match("")
      end

      it 'returns status code 401' do
        expect(response).to have_http_status(401)
      end
    end

    context 'when not authorized' do
      before { get "/companies/#{company.id}" }

      it 'returns status code 401' do
        expect(response).to have_http_status(401)
      end

      it 'returns a not found message' do
        expect(response.body).to match("")
      end
    end
  end

  # Test suite for GET /users/1/companies/1
  describe 'GET /users/1/companies/1' do
    context 'when the record exists' do
      before do
        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        get "/users/#{user.id}/companies/#{company.id}", headers: { 'Authorization': token }
      end

      it 'returns the company' do
        expect(json).not_to be_empty
        expect(json['id']).to eq(company.id)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when the record does not exist' do
      let(:company_id) { 0 }

      before do
        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        get "/users/#{user.id}/companies/#{company_id}", headers: { 'Authorization': token }
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

        get "/users/#{user.id}/companies/#{company.id}", headers: {'Authorization': token}
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
        post "/auth/login", params: {email: user.email, password: password}
        token = json['token']

        get "/users/#{user.id}/companies/#{company2.id}", headers: {'Authorization': token}
      end

      it "returns nothing" do
        expect(response.body).to match("")
      end

      it 'returns status code 403' do
        expect(response).to have_http_status(403)
      end
    end

    context 'when not authorized' do
      before { get "/users/1/companies/#{company.id}" }

      it 'returns status code 401' do
        expect(response).to have_http_status(401)
      end

      it 'returns a not found message' do
        expect(response.body).to match("")
      end
    end
  end

  # Test suite for POST /users/1/companies/
  describe 'POST /users/1/companies' do
    context 'when the request is valid' do
      before do
        post "/auth/login", params: { email: new_user.email, password: password}
        token = json['token']

        post "/users/#{new_user.id}/companies", params: valid_attributes, headers: { 'Authorization': token }
      end

      it 'creates a company' do
        expect(json['name']).to eq('name')
        expect(json['description']).to eq('description')
        expect(json['website']).to eq('domain.com')
        expect(user.company).not_to be_nil
      end

      it 'returns status code 201' do
        expect(response).to have_http_status(201)
      end
    end

    context 'when the request without name' do
      before do
        post "/auth/login", params: { email: new_user.email, password: password}
        token = json['token']

        post "/users/#{new_user.id}/companies", params: without_name, headers: { 'Authorization': token }
      end

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a validation failure message' do
        expect(response.body)
          .to match("{\"name\":[\"can't be blank\"]}")
      end
    end

    context 'when the request without website' do
      before do
        post "/auth/login", params: { email: new_user.email, password: password}
        token = json['token']

        post "/users/#{new_user.id}/companies", params: without_website, headers: { 'Authorization': token }
      end

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a validation failure message' do
        expect(response.body)
          .to match("{\"website\":[\"can't be blank\"]}")
      end
    end

    context 'when already have company' do
      before do
        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        post "/users/#{user.id}/companies", params: valid_attributes, headers: { 'Authorization': token }
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

        post "/users/#{new_user.id}/companies", params: valid_attributes, headers: { 'Authorization': token }
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
        post "/users/1/companies", params: valid_attributes
      end

      it 'returns status code 401' do
        expect(response).to have_http_status(401)
      end

      it 'response is empty' do
        expect(response.body).to match("")
      end
    end
  end

  # Test suite for PATCH /users/1/companies/1
  describe 'PATCH /users/1/companies/1' do
    context 'when the request is valid' do
      before do
        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        patch "/users/#{user.id}/companies/#{company.id}", params: valid_attributes1, headers: { 'Authorization': token }
      end

      it 'updates a company' do
        expect(json['name']).to eq('name1')
        expect(json['description']).to eq('description1')
        expect(json['website']).to eq('domain1.com')
        expect(user.company).not_to be_nil
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when company does not exists' do
      let(:company_id) { 0 }

      before do
        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        patch "/users/#{user.id}/companies/#{company_id}", params: valid_attributes, headers: { 'Authorization': token }
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

        patch "/users/#{user.id}/companies/#{company2.id}", params: valid_attributes, headers: { 'Authorization': token }
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

        patch "/users/#{user.id}/companies/#{company.id}", params: valid_attributes, headers: { 'Authorization': token }
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
        patch "/users/#{user.id}/companies/#{company.id}", params: valid_attributes
      end

      it 'returns status code 401' do
        expect(response).to have_http_status(401)
      end

      it 'response is empty' do
        expect(response.body).to match("")
      end
    end
  end

  # Test suite for DELETE /users/1/companies/1
  describe 'DELETE /users/1/companies/1' do
    context 'when the request is valid' do
      before do
        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        delete "/users/#{user.id}/companies/#{company.id}", params: valid_attributes, headers: { 'Authorization': token }
      end

      it 'response is empty' do
        expect(response.body).to match("")
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when company does not exists' do
      let(:company_id) { 0 }

      before do
        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        delete "/users/#{user.id}/companies/#{company_id}", params: valid_attributes, headers: { 'Authorization': token }
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

        delete "/users/#{user.id}/companies/#{company2.id}", params: valid_attributes, headers: { 'Authorization': token }
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

        delete "/users/#{user.id}/companies/#{company.id}", params: valid_attributes, headers: { 'Authorization': token }
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
        delete "/users/#{user.id}/companies/#{company.id}", params: valid_attributes
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

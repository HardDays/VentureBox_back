require 'rails_helper'

RSpec.describe "Users", type: :request do
  let(:password) { "123123" }
  let!(:user)  { create(:user, password: password, role: :startup) }
  let!(:user2)  { create(:user, password: password, role: :startup) }

  let(:valid_attributes_startup) { { name: "name", surname: "surname", email: "email@email.com", phone: "79510661020",
                             password: password, password_confirmation: password, role: "startup", goals: "goals" } }
  let(:valid_attributes_investor) { { name: "name", surname: "surname", email: "email@email.com", phone: "79510661020",
                             password: password, password_confirmation: password, role: "investor", goals: "goals" } }

  let(:startup_without_name) { { surname: "surname", email: "email@email.com", phone: "79510661020",
                             password: password, password_confirmation: password, role: "startup", goals: "goals" } }
  let(:investor_without_name) { { surname: "surname", email: "email@email.com", phone: "79510661020",
                             password: password, password_confirmation: password, role: "investor", goals: "goals" } }

  let(:startup_without_surname) { { name: "name", email: "email@email.com", phone: "79510661020",
                             password: password, password_confirmation: password, role: "startup", goals: "goals" } }
  let(:investor_without_surname) { { name: "name", email: "email@email.com", phone: "79510661020",
                             password: password, password_confirmation: password, role: "investor", goals: "goals" } }

  let(:startup_without_email) { { name: "name", surname: "surname", phone: "79510661020",
                             password: password, password_confirmation: password, role: "startup", goals: "goals" } }
  let(:investor_without_email) { { name: "name", surname: "surname", phone: "79510661020",
                             password: password, password_confirmation: password, role: "investor", goals: "goals" } }

  let(:startup_without_password) { { name: "name", surname: "surname", email: "email@email.com", phone: "79510661020",
                             role: "startup", goals: "goals" } }
  let(:investor_without_password) { { name: "name", surname: "surname", email: "email@email.com", phone: "79510661020",
                             role: "investor", goals: "goals" } }

  let(:startup_password_not_match) { { name: "name", surname: "surname", email: "email@email.com", phone: "79510661020",
                             password: password, password_confirmation: "123", role: "startup", goals: "goals" } }
  let(:investor_password_not_match) { { name: "name", surname: "surname", email: "email@email.com", phone: "79510661020",
                             password: password, password_confirmation: "123", role: "investor", goals: "goals" } }

  let(:without_role) { { name: "name", surname: "surname", email: "email@email.com", phone: "79510661020",
                             password: password, password_confirmation: password, goals: "goals" } }



  # Test suite for GET /users/1
  describe 'GET /users/1' do
    context 'when the record exists' do
      before do
        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        get "/users/#{user.id}", headers: { 'Authorization': token }
      end

      it 'returns the user' do
        expect(json).not_to be_empty
        expect(json['id']).to eq(user.id)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when not my user' do
      before do
        post "/auth/login", params: {email: user.email, password: password}
        token = json['token']

        get "/users/#{user2.id}", headers: {'Authorization': token}
      end

      it "returns nothing" do
        expect(response.body).to match("")
      end

      it 'returns status code 403' do
        expect(response).to have_http_status(403)
      end
    end

    context 'when not authorized' do
      before { get "/users/#{user.id}" }

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

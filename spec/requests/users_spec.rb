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

  let(:startup_email_invalid) { { name: "name", surname: "surname", email: "emailemail.com", phone: "79510661020",
                             password: password, password_confirmation: password, role: "startup", goals: "goals" } }
  let(:investor_email_invalid) { { name: "name", surname: "surname", email: "emailemail.com", phone: "79510661020",
                             password: password, password_confirmation: password, role: "investor", goals: "goals" } }

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

  # Test suite for POST /users/
  describe 'POST /users/' do
    context 'startup' do
      context 'when the request is valid' do
        before do
          post "/users", params: valid_attributes_startup
        end

        it 'creates a user' do
          expect(json['name']).to eq('name')
          expect(json['surname']).to eq('surname')
          expect(json['email']).to eq('email@email.com')
          expect(json['role']).to eq('startup')
          expect(json['phone']).to eq('79510661020')
          expect(json['goals']).to eq('goals')
          expect(json['password']).not_to be_present
        end

        it 'returns status code 201' do
          expect(response).to have_http_status(201)
        end
      end

      context 'when the request without name' do
        before do
          post "/users", params: startup_without_name
        end

        it 'returns status code 422' do
          expect(response).to have_http_status(422)
        end

        it 'returns a validation failure message' do
          expect(response.body)
            .to match("{\"name\":[\"can't be blank\"]}")
        end
      end

      context 'when the request without surname' do
        before do
          post "/users", params: startup_without_surname
        end

        it 'returns status code 422' do
          expect(response).to have_http_status(422)
        end

        it 'returns a validation failure message' do
          expect(response.body)
            .to match("{\"surname\":[\"can't be blank\"]}")
        end
      end

      context 'when the request without email' do
        before do
          post "/users", params: startup_without_email
        end

        it 'returns status code 422' do
          expect(response).to have_http_status(422)
        end

        it 'returns a validation failure message' do
          expect(response.body)
            .to match("{\"email\":[\"can't be blank\"]}")
        end
      end

      context 'when the request without password' do
        before do
          post "/users", params: startup_without_password
        end

        it 'returns status code 422' do
          expect(response).to have_http_status(422)
        end

        it 'returns a validation failure message' do
          expect(response.body)
            .to match("{\"password\":[\"can't be blank\"]}")
        end
      end

      context 'when the request password not match' do
        before do
          post "/users", params: startup_password_not_match
        end

        it 'returns status code 422' do
          expect(response).to have_http_status(422)
        end

        it 'returns a validation failure message' do
          expect(response.body)
            .to match("{\"password_confirmation\":[\"NOT_MATCHED\"]}")
        end
      end

      context 'when the request email not valid' do
        before do
          post "/users", params: startup_email_invalid
        end

        it 'returns status code 422' do
          expect(response).to have_http_status(422)
        end

        it 'returns a validation failure message' do
          expect(response.body)
            .to match("{\"email\":[\"is invalid\"]}")
        end
      end
    end

    context 'investor' do
      context 'when the request is valid' do
        before do
          post "/users", params: valid_attributes_investor
        end

        it 'creates a user' do
          expect(json['name']).to eq('name')
          expect(json['surname']).to eq('surname')
          expect(json['email']).to eq('email@email.com')
          expect(json['role']).to eq('investor')
          expect(json['phone']).to eq('79510661020')
          expect(json['goals']).to eq('goals')
          expect(json['password']).not_to be_present
        end

        it 'returns status code 201' do
          expect(response).to have_http_status(201)
        end
      end

      context 'when the request without name' do
        before do
          post "/users", params: investor_without_name
        end

        it 'returns status code 422' do
          expect(response).to have_http_status(422)
        end

        it 'returns a validation failure message' do
          expect(response.body)
            .to match("{\"name\":[\"can't be blank\"]}")
        end
      end

      context 'when the request without surname' do
        before do
          post "/users", params: investor_without_surname
        end

        it 'returns status code 422' do
          expect(response).to have_http_status(422)
        end

        it 'returns a validation failure message' do
          expect(response.body)
            .to match("{\"surname\":[\"can't be blank\"]}")
        end
      end

      context 'when the request without email' do
        before do
          post "/users", params: investor_without_email
        end

        it 'returns status code 422' do
          expect(response).to have_http_status(422)
        end

        it 'returns a validation failure message' do
          expect(response.body)
            .to match("{\"email\":[\"can't be blank\"]}")
        end
      end

      context 'when the request without password' do
        before do
          post "/users", params: investor_without_password
        end

        it 'returns status code 422' do
          expect(response).to have_http_status(422)
        end

        it 'returns a validation failure message' do
          expect(response.body)
            .to match("{\"password\":[\"can't be blank\"]}")
        end
      end

      context 'when the request password not match' do
        before do
          post "/users", params: investor_password_not_match
        end

        it 'returns status code 422' do
          expect(response).to have_http_status(422)
        end

        it 'returns a validation failure message' do
          expect(response.body)
            .to match("{\"password_confirmation\":[\"NOT_MATCHED\"]}")
        end
      end

      context 'when the request email not valid' do
        before do
          post "/users", params: investor_email_invalid
        end

        it 'returns status code 422' do
          expect(response).to have_http_status(422)
        end

        it 'returns a validation failure message' do
          expect(response.body)
            .to match("{\"email\":[\"is invalid\"]}")
        end
      end
    end

    context 'creation without role' do
      before do
        post "/users", params: without_role
      end

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a validation failure message' do
        expect(response.body)
          .to match("{\"role\":[\"can't be blank\"]}")
      end
    end
  end

  # Test suite for PATCH /users/1
  describe 'PATCH /users/1' do
    # TODO:
  end

  # Test suite for DELETE /users/1
  describe 'DELETE /users/1' do
    context 'when the request is valid' do
      before do
        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        delete "/users/#{user.id}", headers: { 'Authorization': token }
      end

      it 'response is empty' do
        expect(response.body).to match("")
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when user does not exists' do
      let(:user_id) { 0 }

      before do
        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        delete "/users/#{user_id}", headers: { 'Authorization': token }
      end

      it 'response is empty' do
        expect(response.body).to match("")
      end

      it 'returns status code 403' do
        expect(response).to have_http_status(403)
      end
    end

    context 'when not my user' do
      before do
        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        delete "/users/#{user2.id}", headers: { 'Authorization': token }
      end

      it 'returns status code 403' do
        expect(response).to have_http_status(403)
      end

      it 'response is empty' do
        expect(response.body).to match("")
      end
    end

    context 'when the user unauthorized' do
      before do
        delete "/users/#{user.id}"
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

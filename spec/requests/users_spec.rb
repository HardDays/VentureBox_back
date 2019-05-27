require 'rails_helper'

RSpec.describe "Users", type: :request do
  let(:password) { "123123" }
  let(:new_password) { "asdasd" }
  let(:invalid_password) { "asd" }

  let(:valid_email) { "email@email.com" }
  let(:new_email) { "email1@email.com" }
  let(:invalid_email) { "emailemail.com" }

  let(:name) { "name" }
  let(:new_name) { "name1" }
  let(:surname) { "surname" }
  let(:new_surname) { "surname1" }

  let!(:user)  { create(:user, password: password, password_confirmation: password, role: :startup) }
  let!(:user2)  { create(:user, password: password, password_confirmation: password, role: :startup) }
  let!(:investor_user)  { create(:user, password: password, password_confirmation: password, role: :investor) }

  let(:valid_attributes_startup) { { name: name, surname: surname, email: valid_email, phone: "79510661020",
                             password: password, password_confirmation: password, role: "startup", goals: "goals" } }
  let(:valid_attributes_investor) { { name: name, surname: surname, email: valid_email, phone: "79510661020",
                             password: password, password_confirmation: password, role: "investor", goals: "goals" } }

  let(:startup_without_name) { { surname: surname, email: valid_email, phone: "79510661020",
                             password: password, password_confirmation: password, role: "startup", goals: "goals" } }
  let(:investor_without_name) { { surname: surname, email: valid_email, phone: "79510661020",
                             password: password, password_confirmation: password, role: "investor", goals: "goals" } }

  let(:startup_without_surname) { { name: name, email: valid_email, phone: "79510661020",
                             password: password, password_confirmation: password, role: "startup", goals: "goals" } }
  let(:investor_without_surname) { { name: name, email: valid_email, phone: "79510661020",
                             password: password, password_confirmation: password, role: "investor", goals: "goals" } }

  let(:startup_without_email) { { name: name, surname: surname, phone: "79510661020",
                             password: password, password_confirmation: password, role: "startup", goals: "goals" } }
  let(:investor_without_email) { { name: name, surname: surname, phone: "79510661020",
                             password: password, password_confirmation: password, role: "investor", goals: "goals" } }

  let(:startup_without_password) { { name: name, surname: surname, email: valid_email, phone: "79510661020",
                             role: "startup", goals: "goals" } }
  let(:investor_without_password) { { name: name, surname: surname, email: valid_email, phone: "79510661020",
                             role: "investor", goals: "goals" } }

  let(:startup_password_not_match) { { name: name, surname: surname, email: valid_email, phone: "79510661020",
                             password: password, password_confirmation: "123", role: "startup", goals: "goals" } }
  let(:investor_password_not_match) { { name: name, surname: surname, email: valid_email, phone: "79510661020",
                             password: password, password_confirmation: "123", role: "investor", goals: "goals" } }

  let(:startup_email_invalid) { { name: name, surname: surname, email: invalid_email, phone: "79510661020",
                             password: password, password_confirmation: password, role: "startup", goals: "goals" } }
  let(:investor_email_invalid) { { name: name, surname: surname, email: invalid_email, phone: "79510661020",
                             password: password, password_confirmation: password, role: "investor", goals: "goals" } }

  let(:without_role) { { name: name, surname: surname, email: valid_email, phone: "79510661020",
                             password: password, password_confirmation: password, goals: "goals" } }

  let(:valid_password_change) { { password: new_password, password_confirmation: new_password, old_password: password } }
  let(:without_old_password) { { password: new_password, password_confirmation: new_password } }
  let(:without_confirmation) { { password: new_password, old_password: password } }
  let(:confirmation_not_matched) { { password: new_password, password_confirmation: password, old_password: password } }
  let(:invalid_password_change) { { password: invalid_password, password_confirmation: invalid_password, old_password: password } }

  let(:valid_email_change) { { email: new_email, current_password: password } }
  let(:invalid_email_change) { { email: invalid_email, current_password: password } }
  let(:wrong_old_email) { { email: new_email, current_email: new_email, current_password: password } }
  let(:without_old_email) { { email: new_email, current_password: password } }
  let(:wrong_password) { { email: new_email, current_password: new_email } }
  let(:change_email_without_password) { { email: new_email } }

  let(:change_general) { { name: new_name, surname: new_surname, is_email_notifications_available: true } }
  let(:change_general_without_checkbox) { { name: new_name, surname: new_surname, is_email_notifications_available: false } }
  let(:change_general_without_name) { { surname: new_surname, is_email_notifications_available: true } }
  let(:change_general_without_surname) { { name: new_name, is_email_notifications_available: true } }


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

  # Test suite for GET /users/me
  describe 'GET /users/me' do
    context 'when the record exists' do
      before do
        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        get "/users/me", headers: { 'Authorization': token }
      end

      it 'returns the user' do
        expect(json).not_to be_empty
        expect(json['id']).to eq(user.id)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when not authorized' do
      before { get "/users/me" }

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

  # Test suite for PATCH /users/1/change_password
  describe 'PATCH /users/1/change_password' do
    context 'startup' do
      context 'valid attributes' do
        before do
          post "/auth/login", params: {email: user.email, password: password}
          token = json['token']

          patch "/users/#{user.id}/change_password", params: valid_password_change, headers: {'Authorization': token}
        end

        it "return user" do
          expect(json['name']).to eq(user.name)
          expect(json['surname']).to eq(user.surname)
          expect(json['email']).to eq(user.email)
          expect(json['role']).to eq(user.role)
          expect(json['phone']).to eq(user.phone)
          expect(json['goals']).to eq(user.goals)
          expect(json['password']).not_to be_present
        end

        it 'returns status code 200' do
          expect(response).to have_http_status(200)
        end

        it 'changes password' do
          password_hash = User.encrypt_password(new_password)
          updated_user = User.find(user.id)

          expect(updated_user.password).to eq(password_hash)
        end
      end

      context 'request without old password' do
        before do
          post "/auth/login", params: {email: user.email, password: password}
          token = json['token']

          patch "/users/#{user.id}/change_password", params: without_old_password, headers: {'Authorization': token}
        end

        it "returns error message" do
          expect(response.body)
            .to match("{\"old_password\":[\"MUST_EXIST\"]}")
        end

        it 'returns status code 422' do
          expect(response).to have_http_status(422)
        end
      end

      context 'request without password confirmation' do
        before do
          post "/auth/login", params: {email: user.email, password: password}
          token = json['token']

          patch "/users/#{user.id}/change_password", params: without_confirmation, headers: {'Authorization': token}
        end

        it "returns nothing" do
          expect(response.body)
            .to match("{\"password_confirmation\":[\"MUST_EXIST\"]}")
        end

        it 'returns status code 422' do
          expect(response).to have_http_status(422)
        end
      end

      context 'request without matched confirmation' do
        before do
          post "/auth/login", params: {email: user.email, password: password}
          token = json['token']

          patch "/users/#{user.id}/change_password", params: confirmation_not_matched, headers: {'Authorization': token}
        end

        it "returns nothing" do
          expect(response.body)
            .to match("{\"password_confirmation\":[\"NOT_MATCHED\"]}")
        end

        it 'returns status code 422' do
          expect(response).to have_http_status(422)
        end
      end

      context 'request with invalid password' do
        before do
          post "/auth/login", params: {email: user.email, password: password}
          token = json['token']

          patch "/users/#{user.id}/change_password", params: invalid_password_change, headers: {'Authorization': token}
        end

        it "returns nothing" do
          expect(response.body)
            .to match("{\"password\":[\"is too short (minimum is 6 characters)\"]}")
        end

        it 'returns status code 422' do
          expect(response).to have_http_status(422)
        end
      end

      context 'when not my user' do
        before do
          post "/auth/login", params: {email: user.email, password: password}
          token = json['token']

          patch "/users/#{user2.id}/change_password", headers: {'Authorization': token}
        end

        it "returns nothing" do
          expect(response.body).to match("")
        end

        it 'returns status code 403' do
          expect(response).to have_http_status(403)
        end
      end

      context 'when not authorized' do
        before { patch "/users/#{user.id}/change_password" }

        it 'returns status code 401' do
          expect(response).to have_http_status(401)
        end

        it 'returns a not found message' do
          expect(response.body).to match("")
        end
      end
    end

    context 'investor' do
      context 'valid attributes' do
        before do
          post "/auth/login", params: {email: investor_user.email, password: password}
          token = json['token']

          patch "/users/#{investor_user.id}/change_password", params: valid_password_change, headers: {'Authorization': token}
        end

        it "return user" do
          expect(json['name']).to eq(investor_user.name)
          expect(json['surname']).to eq(investor_user.surname)
          expect(json['email']).to eq(investor_user.email)
          expect(json['role']).to eq(investor_user.role)
          expect(json['phone']).to eq(investor_user.phone)
          expect(json['goals']).to eq(investor_user.goals)
          expect(json['password']).not_to be_present
        end

        it 'returns status code 200' do
          expect(response).to have_http_status(200)
        end

        it 'changes password' do
          password_hash = User.encrypt_password(new_password)
          updated_user = User.find(investor_user.id)

          expect(updated_user.password).to eq(password_hash)
        end
      end

      context 'request without old password' do
        before do
          post "/auth/login", params: {email: investor_user.email, password: password}
          token = json['token']

          patch "/users/#{investor_user.id}/change_password", params: without_old_password, headers: {'Authorization': token}
        end

        it "returns nothing" do
          expect(response.body)
            .to match("{\"old_password\":[\"MUST_EXIST\"]}")
        end

        it 'returns status code 422' do
          expect(response).to have_http_status(422)
        end
      end

      context 'request without password confirmation' do
        before do
          post "/auth/login", params: {email: investor_user.email, password: password}
          token = json['token']

          patch "/users/#{investor_user.id}/change_password", params: without_confirmation, headers: {'Authorization': token}
        end

        it "returns nothing" do
          expect(response.body)
            .to match("{\"password_confirmation\":[\"MUST_EXIST\"]}")
        end

        it 'returns status code 422' do
          expect(response).to have_http_status(422)
        end
      end

      context 'request without matched confirmation' do
        before do
          post "/auth/login", params: {email: investor_user.email, password: password}
          token = json['token']

          patch "/users/#{investor_user.id}/change_password", params: confirmation_not_matched, headers: {'Authorization': token}
        end

        it "returns nothing" do
          expect(response.body)
            .to match("{\"password_confirmation\":[\"NOT_MATCHED\"]}")
        end

        it 'returns status code 422' do
          expect(response).to have_http_status(422)
        end
      end

      context 'request with invalid password' do
        before do
          post "/auth/login", params: {email: investor_user.email, password: password}
          token = json['token']

          patch "/users/#{investor_user.id}/change_password", params: invalid_password_change, headers: {'Authorization': token}
        end

        it "returns nothing" do
          expect(response.body)
            .to match("{\"password\":[\"is too short (minimum is 6 characters)\"]}")
        end

        it 'returns status code 422' do
          expect(response).to have_http_status(422)
        end
      end

      context 'when not my user' do
        before do
          post "/auth/login", params: {email: investor_user.email, password: password}
          token = json['token']

          patch "/users/#{user2.id}/change_password", headers: {'Authorization': token}
        end

        it "returns nothing" do
          expect(response.body).to match("")
        end

        it 'returns status code 403' do
          expect(response).to have_http_status(403)
        end
      end

      context 'when not authorized' do
        before { patch "/users/#{investor_user.id}/change_password" }

        it 'returns status code 401' do
          expect(response).to have_http_status(401)
        end

        it 'returns a not found message' do
          expect(response.body).to match("")
        end
      end
    end
  end

  # Test suite for PATCH /users/1/change_email
  describe 'PATCH /users/1/change_email' do
    context 'startup' do
      context 'valid attributes' do
        before do
          post "/auth/login", params: {email: user.email, password: password}
          token = json['token']

          valid_email_change[:current_email] = user.email

          patch "/users/#{user.id}/change_email", params: valid_email_change, headers: {'Authorization': token}
        end

        it "return user" do
          expect(json['name']).to eq(user.name)
          expect(json['surname']).to eq(user.surname)
          expect(json['email']).to eq(new_email)
          expect(json['role']).to eq(user.role)
          expect(json['phone']).to eq(user.phone)
          expect(json['goals']).to eq(user.goals)
          expect(json['password']).not_to be_present
        end

        it 'returns status code 200' do
          expect(response).to have_http_status(200)
        end

        it 'changes email' do
          updated_user = User.find(user.id)

          expect(updated_user.email).to eq(new_email)
        end
      end

      context 'request without password' do
        before do
          post "/auth/login", params: {email: user.email, password: password}
          token = json['token']

          change_email_without_password[:current_email] = user.email

          patch "/users/#{user.id}/change_email", params: change_email_without_password, headers: {'Authorization': token}
        end

        it "returns nothing" do
          expect(response.body)
            .to match("{\"current_password\":[\"MUST_EXIST\"]}")
        end

        it 'returns status code 422' do
          expect(response).to have_http_status(422)
        end
      end

      context 'request with wrong password' do
        before do
          post "/auth/login", params: {email: user.email, password: password}
          token = json['token']

          wrong_password[:current_email] = user.email

          patch "/users/#{user.id}/change_email", params: wrong_password, headers: {'Authorization': token}
        end

        it "returns nothing" do
          expect(response.body)
            .to match("{\"current_password\":[\"NOT_MACHED\"]}")
        end

        it 'returns status code 422' do
          expect(response).to have_http_status(422)
        end
      end

      context 'request without old email' do
        before do
          post "/auth/login", params: {email: user.email, password: password}
          token = json['token']

          patch "/users/#{user.id}/change_email", params: without_old_email, headers: {'Authorization': token}
        end

        it "returns nothing" do
          expect(response.body)
            .to match("{\"current_email\":[\"MUST_EXIST\"]}")
        end

        it 'returns status code 422' do
          expect(response).to have_http_status(422)
        end
      end

      context 'request with wrong old password' do
        before do
          post "/auth/login", params: {email: user.email, password: password}
          token = json['token']

          patch "/users/#{user.id}/change_email", params: wrong_old_email, headers: {'Authorization': token}
        end

        it "returns nothing" do
          expect(response.body)
            .to match("{\"current_email\":[\"NOT_MACHED\"]}")
        end

        it 'returns status code 422' do
          expect(response).to have_http_status(422)
        end
      end

      context 'request with invalid email' do
        before do
          post "/auth/login", params: {email: user.email, password: password}
          token = json['token']

          invalid_email_change[:current_email] = user.email

          patch "/users/#{user.id}/change_email", params: invalid_email_change, headers: {'Authorization': token}
        end

        it "returns nothing" do
          expect(response.body)
            .to match("{\"email\":[\"is invalid\"]}")
        end

        it 'returns status code 422' do
          expect(response).to have_http_status(422)
        end
      end

      context 'when not my user' do
        before do
          post "/auth/login", params: {email: user.email, password: password}
          token = json['token']

          patch "/users/#{user2.id}/change_email", headers: {'Authorization': token}
        end

        it "returns nothing" do
          expect(response.body).to match("")
        end

        it 'returns status code 403' do
          expect(response).to have_http_status(403)
        end
      end

      context 'when not authorized' do
        before { patch "/users/#{user.id}/change_email" }

        it 'returns status code 401' do
          expect(response).to have_http_status(401)
        end

        it 'returns a not found message' do
          expect(response.body).to match("")
        end
      end
    end

    context 'investor' do
      context 'valid attributes' do
        before do
          post "/auth/login", params: {email: investor_user.email, password: password}
          token = json['token']

          valid_email_change[:current_email] = investor_user.email

          patch "/users/#{investor_user.id}/change_email", params: valid_email_change, headers: {'Authorization': token}
        end

        it "return user" do
          expect(json['name']).to eq(investor_user.name)
          expect(json['surname']).to eq(investor_user.surname)
          expect(json['email']).to eq(new_email)
          expect(json['role']).to eq(investor_user.role)
          expect(json['phone']).to eq(investor_user.phone)
          expect(json['goals']).to eq(investor_user.goals)
          expect(json['password']).not_to be_present
        end

        it 'returns status code 200' do
          expect(response).to have_http_status(200)
        end

        it 'changes email' do
          updated_user = User.find(investor_user.id)

          expect(updated_user.email).to eq(new_email)
        end
      end

      context 'request without password' do
        before do
          post "/auth/login", params: {email: investor_user.email, password: password}
          token = json['token']

          change_email_without_password[:current_email] = investor_user.email

          patch "/users/#{investor_user.id}/change_email", params: change_email_without_password, headers: {'Authorization': token}
        end

        it "returns nothing" do
          expect(response.body)
            .to match("{\"current_password\":[\"MUST_EXIST\"]}")
        end

        it 'returns status code 422' do
          expect(response).to have_http_status(422)
        end
      end

      context 'request with wrong password' do
        before do
          post "/auth/login", params: {email: investor_user.email, password: password}
          token = json['token']

          wrong_password[:current_email] = investor_user.email

          patch "/users/#{investor_user.id}/change_email", params: wrong_password, headers: {'Authorization': token}
        end

        it "returns nothing" do
          expect(response.body)
            .to match("{\"current_password\":[\"NOT_MACHED\"]}")
        end

        it 'returns status code 422' do
          expect(response).to have_http_status(422)
        end
      end

      context 'request without old email' do
        before do
          post "/auth/login", params: {email: investor_user.email, password: password}
          token = json['token']

          patch "/users/#{investor_user.id}/change_email", params: without_old_email, headers: {'Authorization': token}
        end

        it "returns nothing" do
          expect(response.body)
            .to match("{\"current_email\":[\"MUST_EXIST\"]}")
        end

        it 'returns status code 422' do
          expect(response).to have_http_status(422)
        end
      end

      context 'request with wrong old password' do
        before do
          post "/auth/login", params: {email: investor_user.email, password: password}
          token = json['token']

          patch "/users/#{investor_user.id}/change_email", params: wrong_old_email, headers: {'Authorization': token}
        end

        it "returns nothing" do
          expect(response.body)
            .to match("{\"current_email\":[\"NOT_MACHED\"]}")
        end

        it 'returns status code 422' do
          expect(response).to have_http_status(422)
        end
      end

      context 'request with invalid email' do
        before do
          post "/auth/login", params: {email: investor_user.email, password: password}
          token = json['token']

          invalid_email_change[:current_email] = investor_user.email

          patch "/users/#{investor_user.id}/change_email", params: invalid_email_change, headers: {'Authorization': token}
        end

        it "returns nothing" do
          expect(response.body)
            .to match("{\"email\":[\"is invalid\"]}")
        end

        it 'returns status code 422' do
          expect(response).to have_http_status(422)
        end
      end

      context 'when not my user' do
        before do
          post "/auth/login", params: {email: investor_user.email, password: password}
          token = json['token']

          patch "/users/#{user2.id}/change_email", headers: {'Authorization': token}
        end

        it "returns nothing" do
          expect(response.body).to match("")
        end

        it 'returns status code 403' do
          expect(response).to have_http_status(403)
        end
      end

      context 'when not authorized' do
        before { patch "/users/#{investor_user.id}/change_email" }

        it 'returns status code 401' do
          expect(response).to have_http_status(401)
        end

        it 'returns a not found message' do
          expect(response.body).to match("")
        end
      end
    end
  end

  # Test suite for PATCH /users/1/change_general
  describe 'PATCH /users/1/change_general' do
    context 'startup' do
      context 'valid attributes' do
        before do
          post "/auth/login", params: {email: user.email, password: password}
          token = json['token']

          patch "/users/#{user.id}/change_general", params: change_general, headers: {'Authorization': token}
        end

        it "return user" do
          expect(json['name']).to eq(new_name)
          expect(json['surname']).to eq(new_surname)
          expect(json['email']).to eq(user.email)
          expect(json['role']).to eq(user.role)
          expect(json['phone']).to eq(user.phone)
          expect(json['goals']).to eq(user.goals)
          expect(json['is_email_notifications_available']).to eq(true)
          expect(json['password']).not_to be_present
        end

        it 'returns status code 200' do
          expect(response).to have_http_status(200)
        end

        it 'changes general info' do
          updated_user = User.find(user.id)

          expect(updated_user.name).to eq(new_name)
          expect(updated_user.surname).to eq(new_surname)
          expect(updated_user.is_email_notifications_available).to eq(true)
        end
      end

      context 'valid attributes' do
        before do
          post "/auth/login", params: {email: user.email, password: password}
          token = json['token']

          patch "/users/#{user.id}/change_general", params: change_general_without_checkbox, headers: {'Authorization': token}
        end

        it "return user" do
          expect(json['name']).to eq(new_name)
          expect(json['surname']).to eq(new_surname)
          expect(json['is_email_notifications_available']).to eq(false)
          expect(json['email']).to eq(user.email)
          expect(json['role']).to eq(user.role)
          expect(json['phone']).to eq(user.phone)
          expect(json['goals']).to eq(user.goals)
          expect(json['password']).not_to be_present
        end

        it 'returns status code 200' do
          expect(response).to have_http_status(200)
        end

        it 'changes general info' do
          updated_user = User.find(user.id)

          expect(updated_user.name).to eq(new_name)
          expect(updated_user.surname).to eq(new_surname)
          expect(updated_user.is_email_notifications_available).to eq(false)
        end
      end

      context 'request without name' do
        before do
          post "/auth/login", params: {email: user.email, password: password}
          token = json['token']

          patch "/users/#{user.id}/change_general", params: change_general_without_name, headers: {'Authorization': token}
        end

        it "return user" do
          expect(json['name']).to eq(user.name)
          expect(json['surname']).to eq(new_surname)
          expect(json['is_email_notifications_available']).to eq(true)
          expect(json['email']).to eq(user.email)
          expect(json['role']).to eq(user.role)
          expect(json['phone']).to eq(user.phone)
          expect(json['goals']).to eq(user.goals)
          expect(json['password']).not_to be_present
        end

        it 'returns status code 200' do
          expect(response).to have_http_status(200)
        end

        it 'changes doesnt changes name' do
          updated_user = User.find(user.id)

          expect(updated_user.name).to eq(user.name)
        end
      end

      context 'request without surname' do
        before do
          post "/auth/login", params: {email: user.email, password: password}
          token = json['token']

          patch "/users/#{user.id}/change_general", params: change_general_without_surname, headers: {'Authorization': token}
        end

        it "return user" do
          expect(json['name']).to eq(new_name)
          expect(json['surname']).to eq(user.surname)
          expect(json['is_email_notifications_available']).to eq(true)
          expect(json['email']).to eq(user.email)
          expect(json['role']).to eq(user.role)
          expect(json['phone']).to eq(user.phone)
          expect(json['goals']).to eq(user.goals)
          expect(json['password']).not_to be_present
        end

        it 'returns status code 200' do
          expect(response).to have_http_status(200)
        end

        it 'changes doesnt changes surname' do
          updated_user = User.find(user.id)

          expect(updated_user.surname).to eq(user.surname)
        end
      end

      context 'when not my user' do
        before do
          post "/auth/login", params: {email: user.email, password: password}
          token = json['token']

          patch "/users/#{user2.id}/change_general", headers: {'Authorization': token}
        end

        it "returns nothing" do
          expect(response.body).to match("")
        end

        it 'returns status code 403' do
          expect(response).to have_http_status(403)
        end
      end

      context 'when not authorized' do
        before { patch "/users/#{user.id}/change_general" }

        it 'returns status code 401' do
          expect(response).to have_http_status(401)
        end

        it 'returns a not found message' do
          expect(response.body).to match("")
        end
      end
    end

    context 'investor' do
      context 'valid attributes' do
        before do
          post "/auth/login", params: {email: investor_user.email, password: password}
          token = json['token']

          patch "/users/#{investor_user.id}/change_general", params: change_general, headers: {'Authorization': token}
        end

        it "return user" do
          expect(json['name']).to eq(new_name)
          expect(json['surname']).to eq(new_surname)
          expect(json['is_email_notifications_available']).to eq(true)
          expect(json['email']).to eq(investor_user.email)
          expect(json['role']).to eq(investor_user.role)
          expect(json['phone']).to eq(investor_user.phone)
          expect(json['goals']).to eq(investor_user.goals)
          expect(json['password']).not_to be_present
        end

        it 'returns status code 200' do
          expect(response).to have_http_status(200)
        end

        it 'changes general info' do
          updated_user = User.find(investor_user.id)

          expect(updated_user.name).to eq(new_name)
          expect(updated_user.surname).to eq(new_surname)
          expect(updated_user.is_email_notifications_available).to eq(true)
        end
      end

      context 'valid attributes' do
        before do
          post "/auth/login", params: {email: investor_user.email, password: password}
          token = json['token']

          patch "/users/#{investor_user.id}/change_general", params: change_general_without_checkbox, headers: {'Authorization': token}
        end

        it "return user" do
          expect(json['name']).to eq(new_name)
          expect(json['surname']).to eq(new_surname)
          expect(json['is_email_notifications_available']).to eq(false)
          expect(json['email']).to eq(investor_user.email)
          expect(json['role']).to eq(investor_user.role)
          expect(json['phone']).to eq(investor_user.phone)
          expect(json['goals']).to eq(investor_user.goals)
          expect(json['password']).not_to be_present
        end

        it 'returns status code 200' do
          expect(response).to have_http_status(200)
        end

        it 'changes general info' do
          updated_user = User.find(investor_user.id)

          expect(updated_user.name).to eq(new_name)
          expect(updated_user.surname).to eq(new_surname)
          expect(updated_user.is_email_notifications_available).to eq(false)
        end
      end

      context 'request without name' do
        before do
          post "/auth/login", params: {email: investor_user.email, password: password}
          token = json['token']

          patch "/users/#{investor_user.id}/change_general", params: change_general_without_name, headers: {'Authorization': token}
        end

        it "return user" do
          expect(json['name']).to eq(investor_user.name)
          expect(json['surname']).to eq(new_surname)
          expect(json['is_email_notifications_available']).to eq(true)
          expect(json['email']).to eq(investor_user.email)
          expect(json['role']).to eq(investor_user.role)
          expect(json['phone']).to eq(investor_user.phone)
          expect(json['goals']).to eq(investor_user.goals)
          expect(json['password']).not_to be_present
        end

        it 'returns status code 200' do
          expect(response).to have_http_status(200)
        end

        it 'changes doesnt changes name' do
          updated_user = User.find(investor_user.id)

          expect(updated_user.name).to eq(investor_user.name)
        end
      end

      context 'request without surname' do
        before do
          post "/auth/login", params: {email: investor_user.email, password: password}
          token = json['token']

          patch "/users/#{investor_user.id}/change_general", params: change_general_without_surname, headers: {'Authorization': token}
        end

        it "return user" do
          expect(json['name']).to eq(new_name)
          expect(json['surname']).to eq(investor_user.surname)
          expect(json['is_email_notifications_available']).to eq(true)
          expect(json['email']).to eq(investor_user.email)
          expect(json['role']).to eq(investor_user.role)
          expect(json['phone']).to eq(investor_user.phone)
          expect(json['goals']).to eq(investor_user.goals)
          expect(json['password']).not_to be_present
        end

        it 'returns status code 200' do
          expect(response).to have_http_status(200)
        end

        it 'changes doesnt changes surname' do
          updated_user = User.find(investor_user.id)

          expect(updated_user.surname).to eq(investor_user.surname)
        end
      end

      context 'when not my user' do
        before do
          post "/auth/login", params: {email: investor_user.email, password: password}
          token = json['token']

          patch "/users/#{user2.id}/change_general", headers: {'Authorization': token}
        end

        it "returns nothing" do
          expect(response.body).to match("")
        end

        it 'returns status code 403' do
          expect(response).to have_http_status(403)
        end
      end

      context 'when not authorized' do
        before { patch "/users/#{investor_user.id}/change_general" }

        it 'returns status code 401' do
          expect(response).to have_http_status(401)
        end

        it 'returns a not found message' do
          expect(response.body).to match("")
        end
      end
    end
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

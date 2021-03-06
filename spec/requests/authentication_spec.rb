require 'rails_helper'

RSpec.describe 'Auth API', type: :request do
  # initialize test data
  let!(:user) { create(:user, email: "aaa@aaa.com", password: "123123", password_confirmation: "123123", status: :approved) }
  let(:email) { Faker::Internet.email }
  let(:password) { "123123" }

  let(:valid_attributes) { { email: user.email, password: "123123" } }
  let(:wrong_password) { { email: user.email, password: "123" } }
  let(:wrong_email) { { email: 'aaa.aaa', password: "123123" } }


  # Test suite for POST /auth/login
  describe 'POST /auth/login' do
    context 'when the request is valid' do
      before { post '/auth/login', params: valid_attributes }

      it 'logins a user' do
        expect(json['token']).to be_kind_of(String)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when the password invalid' do
      before { post '/auth/login', params: wrong_password }

      it 'returns status code 403' do
        expect(response).to have_http_status(403)
      end
    end

    context 'when the email invalid' do
      before { post '/auth/login', params: wrong_email }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end
    end

    context 'when the password not given' do
      before { post '/auth/login', params: {email: user.email} }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end
    end

    context 'when the email not given' do
      before { post '/auth/login', params: {password: password} }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end
    end
  end

  # Test suite for POST /auth/logout
  describe 'POST /auth/logout' do
    context 'when the request is valid' do
      before do
        post "/auth/login", params: { email: user.email, password: password }
        token = Token.find_by(user_id: user.id)

        post "/auth/logout", headers: { 'Authorization': token.token }
      end

      it 'sends nothing' do
        expect(response.body).to match("")
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when the request is invalid' do
      before do
        post "/auth/logout"
      end

      it 'sends nothing' do
        expect(response.body).to match("")
      end

      it 'returns status code 401' do
        expect(response).to have_http_status(401)
      end
    end
  end

  # Test suite for POST /auth/forgot_password
  describe 'POST /auth/forgot_password' do
    context 'when the user exists' do
      before do
        post "/auth/forgot_password", params: { email: user.email }
      end

      it 'sends nothing' do
        expect(response.body).to match("")
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when everything right' do
      before do
        post "/auth/forgot_password", params: { email: user.email }

        post '/auth/login', params: valid_attributes
      end

      it 'do not logins with previous credentials' do
        expect(response.body).to match("")
      end

      it 'returns status code 403' do
        expect(response).to have_http_status(403)
      end
    end

    context 'when the user don\'t exists' do
      before do
        post "/auth/forgot_password", params: { email: email }
      end

      it 'sends nothing' do
        expect(response.body).to match("")
      end

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end
    end

    context 'when the user made to many attempts' do
      before do
        post "/auth/forgot_password", params: { email: user.email }
        post "/auth/forgot_password", params: { email: user.email }
        post "/auth/forgot_password", params: { email: user.email }
        post "/auth/forgot_password", params: { email: user.email }
      end

      it 'sends nothing' do
        expect(response.body).to match("")
      end

      it 'returns status code 400' do
        expect(response).to have_http_status(400)
      end
    end
  end
end

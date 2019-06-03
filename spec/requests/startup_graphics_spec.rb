require 'rails_helper'

RSpec.describe "StartupGraphicsSpec", type: :request do
  let(:password) { "123123" }
  let!(:user)  { create(:user, password: password, password_confirmation: password, role: :startup) }
  let!(:company) { create(:company, user_id: user.id) }
  let!(:company_item) { create(:company_item, company_id: company.id) }
  let!(:company_item2) { create(:company_item, company_id: company.id) }
  let!(:company_item3) { create(:company_item, company_id: company.id) }

  let!(:user2)  { create(:user, password: password, password_confirmation: password, role: :startup) }
  let!(:company2) { create(:company, user_id: user2.id) }

  let!(:investor) { create(:user, password: password, password_confirmation: password, role: :investor )}
  let!(:invested_company) { create(:invested_company, investment: 100, company_id: company.id, investor_id: investor.id )}


  # Test suite for GET /users/1/companies/1/startup_graphics/sales
  describe 'GET /users/1/companies/1/startup_graphics/sales' do
    context 'when simply get' do
      before do
        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        get "/users/#{user.id}/companies/#{company.id}/startup_graphics/sales", headers: { 'Authorization': token }
      end

      it "returns array with all items" do
        expect(json["sales"].count).to match(company.company_items.count)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when no products' do
      before do
        post "/auth/login", params: { email: user2.email, password: password}
        token = json['token']

        get "/users/#{user2.id}/companies/#{company2.id}/startup_graphics/sales", headers: { 'Authorization': token }
      end

      it "returns empty sales" do
        expect(json["sales"]).to match([])
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when i am not startup' do
      before do
        post "/auth/login", params: {email: investor.email, password: password}
        token = json['token']

        get "/users/#{user.id}/companies/#{company.id}/startup_graphics/sales", headers: {'Authorization': token}
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

        get "/users/#{user2.id}/companies/#{company.id}/startup_graphics/sales", headers: {'Authorization': token}
      end

      it "returns nothing" do
        expect(response.body).to match("")
      end

      it 'returns status code 403' do
        expect(response).to have_http_status(403)
      end
    end

    context 'when not authorized' do
      before { get "/users/#{user.id}/companies/#{company.id}/startup_graphics/sales" }

      it 'returns status code 401' do
        expect(response).to have_http_status(401)
      end

      it 'returns a not found message' do
        expect(response.body).to match("")
      end
    end
  end

  # Test suite for GET /users/1/companies/1/startup_graphics/total_earn
  describe 'GET /users/1/companies/1/startup_graphics/total_earn' do
    context 'when simply get' do
      before do
        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        get "/users/#{user.id}/companies/#{company.id}/startup_graphics/total_earn", headers: { 'Authorization': token }
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when i am not startup' do
      before do
        post "/auth/login", params: {email: investor.email, password: password}
        token = json['token']

        get "/users/#{user.id}/companies/#{company.id}/startup_graphics/total_earn", headers: {'Authorization': token}
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

        get "/users/#{user2.id}/companies/#{company.id}/startup_graphics/total_earn", headers: {'Authorization': token}
      end

      it "returns nothing" do
        expect(response.body).to match("")
      end

      it 'returns status code 403' do
        expect(response).to have_http_status(403)
      end
    end

    context 'when not authorized' do
      before { get "/users/#{user.id}/companies/#{company.id}/startup_graphics/total_earn" }

      it 'returns status code 401' do
        expect(response).to have_http_status(401)
      end

      it 'returns a not found message' do
        expect(response.body).to match("")
      end
    end
  end

  # Test suite for GET /users/1/companies/1/startup_graphics/total_investment
  describe 'GET /users/1/companies/1/startup_graphics/total_investment' do
    context 'when simply get' do
      before do
        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        get "/users/#{user.id}/companies/#{company.id}/startup_graphics/total_investment", headers: { 'Authorization': token }
      end

      it "returns all investments" do
        expect(json["total_investment"]).to match(company.investment_amount + 100)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when get vitout investments' do
      before do
        post "/auth/login", params: { email: user2.email, password: password}
        token = json['token']

        get "/users/#{user2.id}/companies/#{company2.id}/startup_graphics/total_investment", headers: { 'Authorization': token }
      end

      it "returns all investments" do
        expect(json["total_investment"]).to match(company2.investment_amount)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when i am not startup' do
      before do
        post "/auth/login", params: {email: investor.email, password: password}
        token = json['token']

        get "/users/#{user.id}/companies/#{company.id}/startup_graphics/total_investment", headers: {'Authorization': token}
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

        get "/users/#{user2.id}/companies/#{company.id}/startup_graphics/total_investment", headers: {'Authorization': token}
      end

      it "returns nothing" do
        expect(response.body).to match("")
      end

      it 'returns status code 403' do
        expect(response).to have_http_status(403)
      end
    end

    context 'when not authorized' do
      before { get "/users/#{user.id}/companies/#{company.id}/startup_graphics/total_investment" }

      it 'returns status code 401' do
        expect(response).to have_http_status(401)
      end

      it 'returns a not found message' do
        expect(response.body).to match("")
      end
    end
  end

  # Test suite for GET /users/1/companies/1/startup_graphics/score
  describe 'GET /users/1/companies/1/startup_graphics/score' do
    context 'when simply get' do
      before do
        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        get "/users/#{user.id}/companies/#{company.id}/startup_graphics/score", headers: { 'Authorization': token }
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when i am not startup' do
      before do
        post "/auth/login", params: {email: investor.email, password: password}
        token = json['token']

        get "/users/#{user.id}/companies/#{company.id}/startup_graphics/score", headers: {'Authorization': token}
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

        get "/users/#{user2.id}/companies/#{company.id}/startup_graphics/score", headers: {'Authorization': token}
      end

      it "returns nothing" do
        expect(response.body).to match("")
      end

      it 'returns status code 403' do
        expect(response).to have_http_status(403)
      end
    end

    context 'when not authorized' do
      before { get "/users/#{user.id}/companies/#{company.id}/startup_graphics/score" }

      it 'returns status code 401' do
        expect(response).to have_http_status(401)
      end

      it 'returns a not found message' do
        expect(response.body).to match("")
      end
    end
  end

  # Test suite for GET /users/1/companies/1/startup_graphics/evaluation
  describe 'GET /users/1/companies/1/startup_graphics/evaluation' do
    context 'when simply get' do
      before do
        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        get "/users/#{user.id}/companies/#{company.id}/startup_graphics/evaluation", headers: { 'Authorization': token }
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when i am not startup' do
      before do
        post "/auth/login", params: {email: investor.email, password: password}
        token = json['token']

        get "/users/#{user.id}/companies/#{company.id}/startup_graphics/evaluation", headers: {'Authorization': token}
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

        get "/users/#{user2.id}/companies/#{company.id}/startup_graphics/evaluation", headers: {'Authorization': token}
      end

      it "returns nothing" do
        expect(response.body).to match("")
      end

      it 'returns status code 403' do
        expect(response).to have_http_status(403)
      end
    end

    context 'when not authorized' do
      before { get "/users/#{user.id}/companies/#{company.id}/startup_graphics/evaluation" }

      it 'returns status code 401' do
        expect(response).to have_http_status(401)
      end

      it 'returns a not found message' do
        expect(response.body).to match("")
      end
    end
  end
end

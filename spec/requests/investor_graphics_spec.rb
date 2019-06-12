require 'rails_helper'

RSpec.describe "InvestorGraphicsSpec", type: :request do
  let(:password) { "123123" }
  let!(:user)  { create(:user, password: password, password_confirmation: password, role: :startup) }
  let!(:company) { create(:company, user_id: user.id, created_at: DateTime.parse("2019-05-07")) }
  let!(:company_item) { create(:company_item, company_id: company.id) }
  let!(:company_item2) { create(:company_item, company_id: company.id) }
  let!(:company_item3) { create(:company_item, company_id: company.id) }

  let!(:user2)  { create(:user, password: password, password_confirmation: password, role: :startup) }
  let!(:company2) { create(:company, user_id: user2.id) }

  let!(:investor) { create(:user, password: password, password_confirmation: password, role: :investor )}
  let!(:invested_company) { create(:invested_company, investment: 100, evaluation: 10, company_id: company.id, investor_id: investor.id, created_at: DateTime.parse("2019-05-18") )}
  let!(:investor2) { create(:user, password: password, password_confirmation: password, role: :investor )}


  # Test suite for GET /users/1/investor_graphics/total_current_value
  describe 'GET /users/1/investor_graphics/total_current_value' do
    context 'when simply get' do
      before do
        post "/auth/login", params: { email: investor.email, password: password}
        token = json['token']

        get "/users/#{investor.id}/investor_graphics/total_current_value", headers: { 'Authorization': token }
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when get by month' do
      before do
        post "/auth/login", params: { email: investor.email, password: password}
        token = json['token']

        get "/users/#{investor.id}/investor_graphics/total_current_value", params: {period: "month"}, headers: { 'Authorization': token }
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when get by year' do
      before do
        post "/auth/login", params: { email: investor.email, password: password}
        token = json['token']

        get "/users/#{investor.id}/investor_graphics/total_current_value", params: {period: "year"}, headers: { 'Authorization': token }
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when get by all' do
      before do
        post "/auth/login", params: { email: investor.email, password: password}
        token = json['token']

        get "/users/#{investor.id}/investor_graphics/total_current_value", params: {period: "all"}, headers: { 'Authorization': token }
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when get by invested company' do
      before do
        post "/auth/login", params: { email: investor.email, password: password}
        token = json['token']

        get "/users/#{investor.id}/investor_graphics/total_current_value", params: {company_id: company.id}, headers: { 'Authorization': token }
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when get by not invested company' do
      before do
        post "/auth/login", params: { email: investor.email, password: password}
        token = json['token']

        get "/users/#{investor.id}/investor_graphics/total_current_value", params: {company_id: company2.id}, headers: { 'Authorization': token }
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when not authorized' do
      before { get "/users/#{user.id}/investor_graphics/total_current_value" }

      it 'returns status code 401' do
        expect(response).to have_http_status(401)
      end

      it 'returns a not found message' do
        expect(response.body).to match("")
      end
    end
  end

  # Test suite for GET /users/1/investor_graphics/amount_of_companies
  describe 'GET /users/1/investor_graphics/amount_of_companies' do
    context 'when simply get' do
      before do
        post "/auth/login", params: { email: investor.email, password: password}
        token = json['token']

        get "/users/#{investor.id}/investor_graphics/amount_of_companies", headers: { 'Authorization': token }
      end

      it "returns all evaluations" do
        expect(json["amount_of_companies"]).to match(1)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when get by many investments' do
      before do
        post "/auth/login", params: { email: investor.email, password: password}
        token = json['token']

        new_investment = InvestedCompany.new(
          investment: 1000,
          evaluation: 10,
          company_id: company.id,
          investor_id: investor2.id,
          contact_email: company.contact_email
        )
        new_investment.save

        get "/users/#{investor.id}/investor_graphics/amount_of_companies", headers: { 'Authorization': token }
      end

      it "returns all evaluations" do
        expect(json["amount_of_companies"]).to match(1)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when not authorized' do
      before { get "/users/#{user.id}/investor_graphics/amount_of_companies" }

      it 'returns status code 401' do
        expect(response).to have_http_status(401)
      end

      it 'returns a not found message' do
        expect(response.body).to match("")
      end
    end
  end

  # Test suite for GET /users/1/investor_graphics/amount_invested
  describe 'GET /users/1/investor_graphics/amount_invested' do
    context 'when simply get' do
      before do
        post "/auth/login", params: { email: investor.email, password: password}
        token = json['token']

        get "/users/#{investor.id}/investor_graphics/amount_invested", headers: { 'Authorization': token }
      end

      it "returns all investments" do
        expect(json["amount_invested"]).to match(100)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when get by invested company' do
      before do
        post "/auth/login", params: { email: investor.email, password: password}
        token = json['token']

        get "/users/#{investor.id}/investor_graphics/amount_invested", params: {company_id: company.id}, headers: { 'Authorization': token }
      end

      it "returns all investments" do
        expect(json["amount_invested"]).to match(100)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when get by not invested company' do
      before do
        post "/auth/login", params: { email: investor.email, password: password}
        token = json['token']

        get "/users/#{investor.id}/investor_graphics/amount_invested", params: {company_id: company2.id}, headers: { 'Authorization': token }
      end

      it "returns all investments" do
        expect(json["amount_invested"]).to match(0)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when not authorized' do
      before { get "/users/#{user.id}/investor_graphics/amount_invested" }

      it 'returns status code 401' do
        expect(response).to have_http_status(401)
      end

      it 'returns a not found message' do
        expect(response.body).to match("")
      end
    end
  end

  # Test suite for GET /users/1/investor_graphics/rate_of_return
  describe 'GET /users/1/investor_graphics/rate_of_returnn' do
    context 'when simply get' do
      before do
        post "/auth/login", params: { email: investor.email, password: password}
        token = json['token']

        get "/users/#{investor.id}/investor_graphics/rate_of_return", headers: { 'Authorization': token }
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when get by month' do
      before do
        post "/auth/login", params: { email: investor.email, password: password}
        token = json['token']

        get "/users/#{investor.id}/investor_graphics/rate_of_return", params: {period: "month"}, headers: { 'Authorization': token }
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when get by year' do
      before do
        post "/auth/login", params: { email: investor.email, password: password}
        token = json['token']

        get "/users/#{investor.id}/investor_graphics/rate_of_return", params: {period: "year"}, headers: { 'Authorization': token }
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when get by all' do
      before do
        post "/auth/login", params: { email: investor.email, password: password}
        token = json['token']

        get "/users/#{investor.id}/investor_graphics/rate_of_return", params: {period: "all"}, headers: { 'Authorization': token }
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when get by invested company' do
      before do
        post "/auth/login", params: { email: investor.email, password: password}
        token = json['token']

        get "/users/#{investor.id}/investor_graphics/rate_of_return", params: {company_id: company.id}, headers: { 'Authorization': token }
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when get by not invested company' do
      before do
        post "/auth/login", params: { email: investor.email, password: password}
        token = json['token']

        get "/users/#{investor.id}/investor_graphics/rate_of_return", params: {company_id: company2.id}, headers: { 'Authorization': token }
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when not authorized' do
      before { get "/users/#{user.id}/investor_graphics/rate_of_return" }

      it 'returns status code 401' do
        expect(response).to have_http_status(401)
      end

      it 'returns a not found message' do
        expect(response.body).to match("")
      end
    end
  end
end

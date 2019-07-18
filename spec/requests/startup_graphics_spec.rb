require 'rails_helper'

RSpec.describe "StartupGraphicsSpec", type: :request do
  let(:password) { "123123" }
  let!(:user)  { create(:user, password: password, password_confirmation: password, role: :startup) }
  let!(:company) { create(:company, user_id: user.id, created_at: "2019-02-01T18:23:51.04+03:00".to_datetime) }
  let!(:company_item) { create(:company_item, company_id: company.id) }
  let!(:company_item2) { create(:company_item, company_id: company.id) }
  let!(:company_item3) { create(:company_item, company_id: company.id) }

  let!(:sale) { create(:shopify_orders_count, company_item: company_item) }
  let!(:sale2) { create(:shopify_orders_count, company_item: company_item2) }
  let!(:sale3) { create(:shopify_orders_count, company_item: company_item3) }

  let!(:user2)  { create(:user, password: password, password_confirmation: password, role: :startup) }
  let!(:company2) { create(:company, user_id: user2.id) }

  let!(:investor) { create(:user, password: password, password_confirmation: password, role: :investor )}
  let!(:invested_company) { create(:invested_company, investment: 100, evaluation: 10, company_id: company.id,
                                   investor_id: investor.id, created_at: "2019-02-01T18:23:51.04+03:00".to_datetime)}


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

    context 'when get without investments' do
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
    context 'when get without params when registered' do
      before do
        t = "2019-02-01T18:23:51".to_datetime
        Timecop.freeze(t)

        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        get "/users/#{user.id}/companies/#{company.id}/startup_graphics/evaluation", headers: { 'Authorization': token }
      end

      it "returns axis and evaluation" do
        expect(json['evaluatons']).to be_present
      end

      it "returns month investment data" do
        total_current_values = [
          {"date" => " 1/Jan", "value" => 0}, {"date" => " 2/Jan", "value" => 0},
          {"date" => " 3/Jan", "value" => 0}, {"date" => " 4/Jan", "value" => 0},
          {"date" => " 5/Jan", "value" => 0}, {"date" => " 6/Jan", "value" => 0},
          {"date" => " 7/Jan", "value" => 0}, {"date" => " 8/Jan", "value" => 0},
          {"date" => " 9/Jan", "value" => 0}, {"date" => "10/Jan", "value" => 0},
          {"date" => "11/Jan", "value" => 0}, {"date" => "12/Jan", "value" => 0},
          {"date" => "13/Jan", "value" => 0}, {"date" => "14/Jan", "value" => 0},
          {"date" => "15/Jan", "value" => 0}, {"date" => "16/Jan", "value" => 0},
          {"date" => "17/Jan", "value" => 0}, {"date" => "18/Jan", "value" => 0},
          {"date" => "19/Jan", "value" => 0}, {"date" => "20/Jan", "value" => 0},
          {"date" => "21/Jan", "value" => 0}, {"date" => "22/Jan", "value" => 0},
          {"date" => "23/Jan", "value" => 0}, {"date" => "24/Jan", "value" => 0},
          {"date" => "25/Jan", "value" => 0}, {"date" => "26/Jan", "value" => 0},
          {"date" => "27/Jan", "value" => 0}, {"date" => "28/Jan", "value" => 0},
          {"date" => "29/Jan", "value" => 0}, {"date" => "30/Jan", "value" => 0},
          {"date" => "31/Jan", "value" => 0}, {"date" => " 1/Feb", "value" => 1000}
        ]

        expect(json['evaluatons']).to eq(total_current_values)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      after do
        Timecop.return
      end
    end

    context 'when get without params' do
      before do
        t = "22 June 2019".to_datetime
        Timecop.freeze(t)

        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        get "/users/#{user.id}/companies/#{company.id}/startup_graphics/evaluation", headers: { 'Authorization': token }
      end

      it "returns axis and total_current_value" do
        expect(json['evaluatons']).to be_present
      end

      it "returns month investment data" do
        total_current_values = [
          {"date" => "22/May", "value" => 1000}, {"date" => "23/May", "value" => 1000},
          {"date" => "24/May", "value" => 1000}, {"date" => "25/May", "value" => 1000},
          {"date" => "26/May", "value" => 1000}, {"date" => "27/May", "value" => 1000},
          {"date" => "28/May", "value" => 1000}, {"date" => "29/May", "value" => 1000},
          {"date" => "30/May", "value" => 1000}, {"date" => "31/May", "value" => 1000},
          {"date" => " 1/Jun", "value" => 1000}, {"date" => " 2/Jun", "value" => 1000},
          {"date" => " 3/Jun", "value" => 1000}, {"date" => " 4/Jun", "value" => 1000},
          {"date" => " 5/Jun", "value" => 1000}, {"date" => " 6/Jun", "value" => 1000},
          {"date" => " 7/Jun", "value" => 1000}, {"date" => " 8/Jun", "value" => 1000},
          {"date" => " 9/Jun", "value" => 1000}, {"date" => "10/Jun", "value" => 1000},
          {"date" => "11/Jun", "value" => 1000}, {"date" => "12/Jun", "value" => 1000},
          {"date" => "13/Jun", "value" => 1000}, {"date" => "14/Jun", "value" => 1000},
          {"date" => "15/Jun", "value" => 1000}, {"date" => "16/Jun", "value" => 1000},
          {"date" => "17/Jun", "value" => 1000}, {"date" => "18/Jun", "value" => 1000},
          {"date" => "19/Jun", "value" => 1000}, {"date" => "20/Jun", "value" => 1000},
          {"date" => "21/Jun", "value" => 1000}, {"date" => "22/Jun", "value" => 1000}
        ]

        expect(json['evaluatons']).to eq(total_current_values)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      after do
        Timecop.return
      end
    end

    context 'when get without params and invested later than beginning of month' do
      before do
        t = "22 June 2019".to_datetime
        Timecop.freeze(t)

        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        invested_company.update_column(:created_at, "20 June 2019")

        get "/users/#{user.id}/companies/#{company.id}/startup_graphics/evaluation", headers: { 'Authorization': token }
      end

      it "returns axis and total_current_value" do
        expect(json['evaluatons']).to be_present
      end

      it "returns month investment data" do
        evaluation = (company.investment_amount / (company.equality_amount * 0.01)).ceil

        total_current_values = [
          {"date" => "22/May", "value" => evaluation}, {"date" => "23/May", "value" => evaluation},
          {"date" => "24/May", "value" => evaluation}, {"date" => "25/May", "value" => evaluation},
          {"date" => "26/May", "value" => evaluation}, {"date" => "27/May", "value" => evaluation},
          {"date" => "28/May", "value" => evaluation}, {"date" => "29/May", "value" => evaluation},
          {"date" => "30/May", "value" => evaluation}, {"date" => "31/May", "value" => evaluation},
          {"date" => " 1/Jun", "value" => evaluation}, {"date" => " 2/Jun", "value" => evaluation},
          {"date" => " 3/Jun", "value" => evaluation}, {"date" => " 4/Jun", "value" => evaluation},
          {"date" => " 5/Jun", "value" => evaluation}, {"date" => " 6/Jun", "value" => evaluation},
          {"date" => " 7/Jun", "value" => evaluation}, {"date" => " 8/Jun", "value" => evaluation},
          {"date" => " 9/Jun", "value" => evaluation}, {"date" => "10/Jun", "value" => evaluation},
          {"date" => "11/Jun", "value" => evaluation}, {"date" => "12/Jun", "value" => evaluation},
          {"date" => "13/Jun", "value" => evaluation}, {"date" => "14/Jun", "value" => evaluation},
          {"date" => "15/Jun", "value" => evaluation}, {"date" => "16/Jun", "value" => evaluation},
          {"date" => "17/Jun", "value" => evaluation}, {"date" => "18/Jun", "value" => evaluation},
          {"date" => "19/Jun", "value" => evaluation}, {"date" => "20/Jun", "value" => 1000},
          {"date" => "21/Jun", "value" => 1000}, {"date" => "22/Jun", "value" => 1000}
        ]

        expect(json['evaluatons']).to eq(total_current_values)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      after do
        Timecop.return
      end
    end

    context 'when get by month when registered' do
      before do
        t = "2019-02-01T18:23:51".to_datetime
        Timecop.freeze(t)

        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        get "/users/#{user.id}/companies/#{company.id}/startup_graphics/evaluation", params: {period: "month"}, headers: { 'Authorization': token }
      end

      it "returns axis and total_current_value" do
        expect(json['evaluatons']).to be_present
      end

      it "returns month investment data" do
        total_current_values = [
          {"date" => " 1/Jan", "value" => 0}, {"date" => " 2/Jan", "value" => 0},
          {"date" => " 3/Jan", "value" => 0}, {"date" => " 4/Jan", "value" => 0},
          {"date" => " 5/Jan", "value" => 0}, {"date" => " 6/Jan", "value" => 0},
          {"date" => " 7/Jan", "value" => 0}, {"date" => " 8/Jan", "value" => 0},
          {"date" => " 9/Jan", "value" => 0}, {"date" => "10/Jan", "value" => 0},
          {"date" => "11/Jan", "value" => 0}, {"date" => "12/Jan", "value" => 0},
          {"date" => "13/Jan", "value" => 0}, {"date" => "14/Jan", "value" => 0},
          {"date" => "15/Jan", "value" => 0}, {"date" => "16/Jan", "value" => 0},
          {"date" => "17/Jan", "value" => 0}, {"date" => "18/Jan", "value" => 0},
          {"date" => "19/Jan", "value" => 0}, {"date" => "20/Jan", "value" => 0},
          {"date" => "21/Jan", "value" => 0}, {"date" => "22/Jan", "value" => 0},
          {"date" => "23/Jan", "value" => 0}, {"date" => "24/Jan", "value" => 0},
          {"date" => "25/Jan", "value" => 0}, {"date" => "26/Jan", "value" => 0},
          {"date" => "27/Jan", "value" => 0}, {"date" => "28/Jan", "value" => 0},
          {"date" => "29/Jan", "value" => 0}, {"date" => "30/Jan", "value" => 0},
          {"date" => "31/Jan", "value" => 0}, {"date" => " 1/Feb", "value" => 1000}
        ]

        expect(json['evaluatons']).to eq(total_current_values)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      after do
        Timecop.return
      end
    end

    context 'when get by month' do
      before do
        t = "22 June 2019".to_datetime
        Timecop.freeze(t)

        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        get "/users/#{user.id}/companies/#{company.id}/startup_graphics/evaluation", params: {period: "month"}, headers: { 'Authorization': token }
      end

      it "returns axis and total_current_value" do
        expect(json['evaluatons']).to be_present
      end

      it "returns month investment data" do
        total_current_values = [
          {"date" => "22/May", "value" => 1000}, {"date" => "23/May", "value" => 1000},
          {"date" => "24/May", "value" => 1000}, {"date" => "25/May", "value" => 1000},
          {"date" => "26/May", "value" => 1000}, {"date" => "27/May", "value" => 1000},
          {"date" => "28/May", "value" => 1000}, {"date" => "29/May", "value" => 1000},
          {"date" => "30/May", "value" => 1000}, {"date" => "31/May", "value" => 1000},
          {"date" => " 1/Jun", "value" => 1000}, {"date" => " 2/Jun", "value" => 1000},
          {"date" => " 3/Jun", "value" => 1000}, {"date" => " 4/Jun", "value" => 1000},
          {"date" => " 5/Jun", "value" => 1000}, {"date" => " 6/Jun", "value" => 1000},
          {"date" => " 7/Jun", "value" => 1000}, {"date" => " 8/Jun", "value" => 1000},
          {"date" => " 9/Jun", "value" => 1000}, {"date" => "10/Jun", "value" => 1000},
          {"date" => "11/Jun", "value" => 1000}, {"date" => "12/Jun", "value" => 1000},
          {"date" => "13/Jun", "value" => 1000}, {"date" => "14/Jun", "value" => 1000},
          {"date" => "15/Jun", "value" => 1000}, {"date" => "16/Jun", "value" => 1000},
          {"date" => "17/Jun", "value" => 1000}, {"date" => "18/Jun", "value" => 1000},
          {"date" => "19/Jun", "value" => 1000}, {"date" => "20/Jun", "value" => 1000},
          {"date" => "21/Jun", "value" => 1000}, {"date" => "22/Jun", "value" => 1000}
        ]

        expect(json['evaluatons']).to eq(total_current_values)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      after do
        Timecop.return
      end
    end

    context 'when get by month and invested later than beginning of month' do
      before do
        t = "22 June 2019".to_datetime
        Timecop.freeze(t)

        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        invested_company.update_column(:created_at, "20 June 2019")

        get "/users/#{user.id}/companies/#{company.id}/startup_graphics/evaluation", params: {period: "month"}, headers: { 'Authorization': token }
      end

      it "returns axis and total_current_value" do
        expect(json['evaluatons']).to be_present
      end

      it "returns month investment data" do
        evaluation = (company.investment_amount / (company.equality_amount * 0.01)).ceil

        total_current_values = [
          {"date" => "22/May", "value" => evaluation}, {"date" => "23/May", "value" => evaluation},
          {"date" => "24/May", "value" => evaluation}, {"date" => "25/May", "value" => evaluation},
          {"date" => "26/May", "value" => evaluation}, {"date" => "27/May", "value" => evaluation},
          {"date" => "28/May", "value" => evaluation}, {"date" => "29/May", "value" => evaluation},
          {"date" => "30/May", "value" => evaluation}, {"date" => "31/May", "value" => evaluation},
          {"date" => " 1/Jun", "value" => evaluation}, {"date" => " 2/Jun", "value" => evaluation},
          {"date" => " 3/Jun", "value" => evaluation}, {"date" => " 4/Jun", "value" => evaluation},
          {"date" => " 5/Jun", "value" => evaluation}, {"date" => " 6/Jun", "value" => evaluation},
          {"date" => " 7/Jun", "value" => evaluation}, {"date" => " 8/Jun", "value" => evaluation},
          {"date" => " 9/Jun", "value" => evaluation}, {"date" => "10/Jun", "value" => evaluation},
          {"date" => "11/Jun", "value" => evaluation}, {"date" => "12/Jun", "value" => evaluation},
          {"date" => "13/Jun", "value" => evaluation}, {"date" => "14/Jun", "value" => evaluation},
          {"date" => "15/Jun", "value" => evaluation}, {"date" => "16/Jun", "value" => evaluation},
          {"date" => "17/Jun", "value" => evaluation}, {"date" => "18/Jun", "value" => evaluation},
          {"date" => "19/Jun", "value" => evaluation}, {"date" => "20/Jun", "value" => 1000},
          {"date" => "21/Jun", "value" => 1000}, {"date" => "22/Jun", "value" => 1000}
        ]

        expect(json['evaluatons']).to eq(total_current_values)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      after do
        Timecop.return
      end
    end

    context 'when get by year when registered' do
      before do
        t = "2019-02-01T18:23:51".to_datetime
        Timecop.freeze(t)

        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        get "/users/#{user.id}/companies/#{company.id}/startup_graphics/evaluation", params: {period: "year"}, headers: { 'Authorization': token }
      end

      it "returns axis and total_current_value" do
        expect(json['evaluatons']).to be_present
      end

      it "returns month investment data" do
        total_current_values = [
          {"date" => "Feb/18", "value" => 0}, {"date" => "Mar/18", "value" => 0},
          {"date" => "Apr/18", "value" => 0}, {"date" => "May/18", "value" => 0},
          {"date" => "Jun/18", "value" => 0}, {"date" => "Jul/18", "value" => 0},
          {"date" => "Aug/18", "value" => 0}, {"date" => "Sep/18", "value" => 0},
          {"date" => "Oct/18", "value" => 0}, {"date" => "Nov/18", "value" => 0},
          {"date" => "Dec/18", "value" => 0}, {"date" => "Jan/19", "value" => 0},
          {"date" => "Feb/19", "value" => 1000}
        ]

        expect(json['evaluatons']).to eq(total_current_values)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      after do
        Timecop.return
      end
    end

    context 'when get by year' do
      before do
        t = "22 June 2020".to_datetime
        Timecop.freeze(t)

        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        get "/users/#{user.id}/companies/#{company.id}/startup_graphics/evaluation", params: {period: "year"}, headers: { 'Authorization': token }
      end

      it "returns axis and total_current_value" do
        expect(json['evaluatons']).to be_present
      end

      it "returns year investment data" do
        total_current_values = [
          {"date" => "Jun/19", "value" => 1000}, {"date" => "Jul/19", "value" => 1000},
          {"date" => "Aug/19", "value" => 1000}, {"date" => "Sep/19", "value" => 1000},
          {"date" => "Oct/19", "value" => 1000}, {"date" => "Nov/19", "value" => 1000},
          {"date" => "Dec/19", "value" => 1000}, {"date" => "Jan/20", "value" => 1000},
          {"date" => "Feb/20", "value" => 1000}, {"date" => "Mar/20", "value" => 1000},
          {"date" => "Apr/20", "value" => 1000}, {"date" => "May/20", "value" => 1000},
          {"date" => "Jun/20", "value" => 1000}
        ]

        expect(json['evaluatons']).to eq(total_current_values)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      after do
        Timecop.return
      end
    end

    context 'when get by year and invested later than beginning of year' do
      before do
        t = "22 June 2020".to_datetime
        Timecop.freeze(t)

        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        invested_company.update_column(:created_at, "20 July 2019")

        get "/users/#{user.id}/companies/#{company.id}/startup_graphics/evaluation", params: {period: "year"}, headers: { 'Authorization': token }
      end

      it "returns axis and total_current_value" do
        expect(json['evaluatons']).to be_present
      end

      it "returns month investment data" do
        evaluation = (company.investment_amount / (company.equality_amount * 0.01)).ceil

        total_current_values = [
          {"date" => "Jun/19", "value" => evaluation}, {"date" => "Jul/19", "value" => 1000},
          {"date" => "Aug/19", "value" => 1000}, {"date" => "Sep/19", "value" => 1000},
          {"date" => "Oct/19", "value" => 1000}, {"date" => "Nov/19", "value" => 1000},
          {"date" => "Dec/19", "value" => 1000}, {"date" => "Jan/20", "value" => 1000},
          {"date" => "Feb/20", "value" => 1000}, {"date" => "Mar/20", "value" => 1000},
          {"date" => "Apr/20", "value" => 1000}, {"date" => "May/20", "value" => 1000},
          {"date" => "Jun/20", "value" => 1000}
        ]

        expect(json['evaluatons']).to eq(total_current_values)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      after do
        Timecop.return
      end
    end

    context 'when get by all and just registered' do
      before do
        t = "2019-02-01T18:23:51.04+03:00".to_datetime
        Timecop.freeze(t)

        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        get "/users/#{user.id}/companies/#{company.id}/startup_graphics/evaluation", params: {period: "all"}, headers: { 'Authorization': token }
      end

      it "returns axis and total_current_value" do
        expect(json['evaluatons']).to be_present
      end

      it "returns year investment data" do
        total_current_values = [{"date" => "18:00", "value" => 1000}]

        expect(json['evaluatons']).to eq(total_current_values)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      after do
        Timecop.return
      end
    end

    context 'when get by all and few hours left' do
      before do
        t = "2019-02-02T06:23:51.04+03:00".to_datetime
        Timecop.freeze(t)

        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        get "/users/#{user.id}/companies/#{company.id}/startup_graphics/evaluation", params: {period: "all"}, headers: { 'Authorization': token }
      end

      it "returns axis and total_current_value" do
        expect(json['evaluatons']).to be_present
      end

      it "returns year investment data" do
        total_current_values = [
          {"date" => "18:00", "value" => 1000}, {"date" => "19:00", "value" => 1000},
          {"date" => "20:00", "value" => 1000}, {"date" => "21:00", "value" => 1000},
          {"date" => "22:00", "value" => 1000}, {"date" => "23:00", "value" => 1000},
          {"date" => "00:00", "value" => 1000}, {"date" => "01:00", "value" => 1000},
          {"date" => "02:00", "value" => 1000}, {"date" => "03:00", "value" => 1000},
          {"date" => "04:00", "value" => 1000}, {"date" => "05:00", "value" => 1000},
          {"date" => "06:00", "value" => 1000}
        ]

        expect(json['evaluatons']).to eq(total_current_values)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      after do
        Timecop.return
      end
    end

    context 'when get by all and few hours left and invested in different times' do
      before do
        t = "2019-02-02T06:23:51.04+03:00".to_datetime
        Timecop.freeze(t)

        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        invested_company.update_column(:created_at, "2019-02-01T20:23:51.04+03:00".to_datetime)

        get "/users/#{user.id}/companies/#{company.id}/startup_graphics/evaluation", params: {period: "all"}, headers: { 'Authorization': token }
      end

      it "returns axis and total_current_value" do
        expect(json['evaluatons']).to be_present
      end

      it "returns year investment data" do
        evaluation = (company.investment_amount / (company.equality_amount * 0.01)).ceil

        total_current_values = [
          {"date" => "18:00", "value" => evaluation}, {"date" => "19:00", "value" => evaluation},
          {"date" => "20:00", "value" => 1000}, {"date" => "21:00", "value" => 1000},
          {"date" => "22:00", "value" => 1000}, {"date" => "23:00", "value" => 1000},
          {"date" => "00:00", "value" => 1000}, {"date" => "01:00", "value" => 1000},
          {"date" => "02:00", "value" => 1000}, {"date" => "03:00", "value" => 1000},
          {"date" => "04:00", "value" => 1000}, {"date" => "05:00", "value" => 1000},
          {"date" => "06:00", "value" => 1000}
        ]

        expect(json['evaluatons']).to eq(total_current_values)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      after do
        Timecop.return
      end
    end

    context 'when get by all and few days left' do
      before do
        t = "2019-02-04T06:23:51.04+03:00".to_datetime
        Timecop.freeze(t)

        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        get "/users/#{user.id}/companies/#{company.id}/startup_graphics/evaluation", params: {period: "all"}, headers: { 'Authorization': token }
      end

      it "returns axis and total_current_value" do
        expect(json['evaluatons']).to be_present
      end

      it "returns year investment data" do
        total_current_values = [
          {"date" => " 1/Feb", "value" => 1000}, {"date" => " 2/Feb", "value" => 1000},
          {"date" => " 3/Feb", "value" => 1000}, {"date" => " 4/Feb", "value" => 1000}
        ]

        expect(json['evaluatons']).to eq(total_current_values)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      after do
        Timecop.return
      end
    end

    context 'when get by all and few days left and invested in different times' do
      before do
        t = "2019-02-04T06:23:51.04+03:00".to_datetime
        Timecop.freeze(t)

        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        invested_company.update_column(:created_at, "2019-02-02T20:23:51.04+03:00".to_datetime)

        get "/users/#{user.id}/companies/#{company.id}/startup_graphics/evaluation", params: {period: "all"}, headers: { 'Authorization': token }
      end

      it "returns axis and total_current_value" do
        expect(json['evaluatons']).to be_present
      end

      it "returns year investment data" do
        evaluation = (company.investment_amount / (company.equality_amount * 0.01)).ceil

        total_current_values = [
          {"date" => " 1/Feb", "value" => evaluation}, {"date" => " 2/Feb", "value" => 1000},
          {"date" => " 3/Feb", "value" => 1000}, {"date" => " 4/Feb", "value" => 1000}
        ]

        expect(json['evaluatons']).to eq(total_current_values)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      after do
        Timecop.return
      end
    end

    context 'when get by all and few weeks left' do
      before do
        t = "2019-02-10T06:23:51.04+03:00".to_datetime
        Timecop.freeze(t)

        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        get "/users/#{user.id}/companies/#{company.id}/startup_graphics/evaluation", params: {period: "all"}, headers: { 'Authorization': token }
      end

      it "returns axis and total_current_value" do
        expect(json['evaluatons']).to be_present
      end

      it "returns year investment data" do
        total_current_values = [
          {"date" => " 1/Feb", "value" => 1000}, {"date" => " 2/Feb", "value" => 1000},
          {"date" => " 3/Feb", "value" => 1000}, {"date" => " 4/Feb", "value" => 1000},
          {"date" => " 5/Feb", "value" => 1000}, {"date" => " 6/Feb", "value" => 1000},
          {"date" => " 7/Feb", "value" => 1000}, {"date" => " 8/Feb", "value" => 1000},
          {"date" => " 9/Feb", "value" => 1000}, {"date" => "10/Feb", "value" => 1000}
        ]

        expect(json['evaluatons']).to eq(total_current_values)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      after do
        Timecop.return
      end
    end

    context 'when get by all and few weeks left and invested in different times' do
      before do
        t = "2019-02-10T06:23:51.04+03:00".to_datetime
        Timecop.freeze(t)

        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        invested_company.update_column(:created_at, "2019-02-02T20:23:51.04+03:00".to_datetime)

        get "/users/#{user.id}/companies/#{company.id}/startup_graphics/evaluation", params: {period: "all"}, headers: { 'Authorization': token }
      end

      it "returns axis and total_current_value" do
        expect(json['evaluatons']).to be_present
      end

      it "returns year investment data" do
        evaluation = (company.investment_amount / (company.equality_amount * 0.01)).ceil

        total_current_values = [
          {"date" => " 1/Feb", "value" => evaluation}, {"date" => " 2/Feb", "value" => 1000},
          {"date" => " 3/Feb", "value" => 1000}, {"date" => " 4/Feb", "value" => 1000},
          {"date" => " 5/Feb", "value" => 1000}, {"date" => " 6/Feb", "value" => 1000},
          {"date" => " 7/Feb", "value" => 1000}, {"date" => " 8/Feb", "value" => 1000},
          {"date" => " 9/Feb", "value" => 1000}, {"date" => "10/Feb", "value" => 1000}
        ]

        expect(json['evaluatons']).to eq(total_current_values)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      after do
        Timecop.return
      end
    end

    context 'when get by all and few month left' do
      before do
        t = "2019-03-10T06:23:51.04+03:00".to_datetime
        Timecop.freeze(t)

        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        get "/users/#{user.id}/companies/#{company.id}/startup_graphics/evaluation", params: {period: "all"}, headers: { 'Authorization': token }
      end

      it "returns axis and total_current_value" do
        expect(json['evaluatons']).to be_present
      end

      it "returns year investment data" do
        total_current_values = [
          {"date" => "Feb/19", "value" => 1000}, {"date" => "Mar/19", "value" => 1000}
        ]

        expect(json['evaluatons']).to eq(total_current_values)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      after do
        Timecop.return
      end
    end

    context 'when get by all and few month left and invested in different times' do
      before do
        t = "2019-07-10T06:23:51.04+03:00".to_datetime
        Timecop.freeze(t)

        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        invested_company.update_column(:created_at, "2019-03-02T20:23:51.04+03:00".to_datetime)

        get "/users/#{user.id}/companies/#{company.id}/startup_graphics/evaluation", params: {period: "all"}, headers: { 'Authorization': token }
      end

      it "returns axis and total_current_value" do
        expect(json['evaluatons']).to be_present
      end

      it "returns year investment data" do
        evaluation = (company.investment_amount / (company.equality_amount * 0.01)).ceil

        total_current_values = [
          {"date" => "Feb/19", "value" => evaluation}, {"date" => "Mar/19", "value" => 1000},
          {"date" => "Apr/19", "value" => 1000}, {"date" => "May/19", "value" => 1000},
          {"date" => "Jun/19", "value" => 1000}, {"date" => "Jul/19", "value" => 1000}
        ]

        expect(json['evaluatons']).to eq(total_current_values)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      after do
        Timecop.return
      end
    end

    context 'when get by all and few years left' do
      before do
        t = "2020-03-10T06:23:51.04+03:00".to_datetime
        Timecop.freeze(t)

        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        get "/users/#{user.id}/companies/#{company.id}/startup_graphics/evaluation", params: {period: "all"}, headers: { 'Authorization': token }
      end

      it "returns axis and total_current_value" do
        expect(json['evaluatons']).to be_present
      end

      it "returns year investment data" do
        total_current_values = [
          {"date" => "2019", "value" => 1000}, {"date" => "2020", "value" => 1000}
        ]

        expect(json['evaluatons']).to eq(total_current_values)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      after do
        Timecop.return
      end
    end

    context 'when get by all and few month left and invested in different times' do
      before do
        t = "2021-07-10T06:23:51.04+03:00".to_datetime
        Timecop.freeze(t)

        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        invested_company.update_column(:created_at, "2020-03-02T20:23:51.04+03:00".to_datetime)

        get "/users/#{user.id}/companies/#{company.id}/startup_graphics/evaluation", params: {period: "all"}, headers: { 'Authorization': token }
      end

      it "returns axis and total_current_value" do
        expect(json['evaluatons']).to be_present
      end

      it "returns year investment data" do
        evaluation = (company.investment_amount / (company.equality_amount * 0.01)).ceil

        total_current_values = [
          {"date" => "2019", "value" => evaluation}, {"date" => "2020","value" => 1000},
          {"date" => "2021", "value" => 1000}
        ]

        expect(json['evaluatons']).to eq(total_current_values)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      after do
        Timecop.return
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

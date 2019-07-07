require 'rails_helper'

RSpec.describe "InvestorGraphicsSpec", type: :request do
  let(:password) { "123123" }
  let!(:user)  { create(:user, password: password, password_confirmation: password, role: :startup) }
  let!(:company) { create(:company, user_id: user.id, created_at: "2019-02-01T18:23:51.04+03:00".to_datetime) }

  let!(:user2)  { create(:user, password: password, password_confirmation: password, role: :startup) }
  let!(:company2) { create(:company, user_id: user2.id, created_at: "2019-02-01T18:23:51.04+03:00".to_datetime) }

  let!(:investor) { create(:user, password: password, password_confirmation: password, role: :investor,
                           created_at: "2019-02-01T18:23:51.04+03:00".to_datetime )}

  let!(:invested_company1) { create(:invested_company, investment: 100, evaluation: 10,
                                   company_id: company.id, investor_id: investor.id,
                                   created_at: "2019-02-01T18:23:51.04+03:00".to_datetime )}
  let!(:invested_company2) { create(:invested_company, investment: 100, evaluation: 10,
                                   company_id: company2.id, investor_id: investor.id,
                                   created_at: "2019-02-01T18:23:51.04+03:00".to_datetime )}
  
  let!(:investor_without_investments) { create(:user, password: password, password_confirmation: password, role: :investor )}


  # Test suite for GET /users/1/investor_graphics/total_current_value
  describe 'GET /users/1/investor_graphics/total_current_value' do
    context 'when get without params when registered' do
      before do
        t = "2019-02-01T18:23:51".to_datetime
        Timecop.freeze(t)

        post "/auth/login", params: { email: investor.email, password: password}
        token = json['token']

        get "/users/#{investor.id}/investor_graphics/total_current_value", headers: { 'Authorization': token }
      end

      it "returns axis and total_current_value" do
        expect(json['axis']).to be_present
        expect(json['total_current_values']).to be_present
      end

      it "returns month axis" do
        axis_dates = [" 1/Jan", " 2/Jan", " 3/Jan", " 4/Jan", " 5/Jan", " 6/Jan", " 7/Jan", " 8/Jan", " 9/Jan",
                      "10/Jan", "11/Jan", "12/Jan", "13/Jan", "14/Jan", "15/Jan", "16/Jan", "17/Jan", "18/Jan",
                      "19/Jan", "20/Jan", "21/Jan", "22/Jan", "23/Jan", "24/Jan", "25/Jan", "26/Jan", "27/Jan",
                      "28/Jan", "29/Jan", "30/Jan", "31/Jan", " 1/Feb"]

        expect(json['axis']).to eq(axis_dates)
      end

      it "returns month investment data" do
        total_current_values = {
          " 1/Jan" => 0, " 2/Jan" => 0, " 3/Jan" => 0, " 4/Jan" => 0, " 5/Jan" => 0, " 6/Jan" => 0,
          " 7/Jan" => 0, " 8/Jan" => 0, " 9/Jan" => 0, "10/Jan" => 0, "11/Jan" => 0, "12/Jan" => 0,
          "13/Jan" => 0, "14/Jan" => 0, "15/Jan" => 0, "16/Jan" => 0, "17/Jan" => 0, "18/Jan" => 0,
          "19/Jan" => 0, "20/Jan" => 0, "21/Jan" => 0, "22/Jan" => 0, "23/Jan" => 0, "24/Jan" => 0,
          "25/Jan" => 0, "26/Jan" => 0, "27/Jan" => 0, "28/Jan" => 0, "29/Jan" => 0, "30/Jan" => 0,
          "31/Jan" => 0, " 1/Feb" => 2000
        }

        expect(json['total_current_values']).to eq(total_current_values)
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

        post "/auth/login", params: { email: investor.email, password: password}
        token = json['token']

        get "/users/#{investor.id}/investor_graphics/total_current_value", headers: { 'Authorization': token }
      end

      it "returns axis and total_current_value" do
        expect(json['axis']).to be_present
        expect(json['total_current_values']).to be_present
      end

      it "returns month axis" do
        axis_dates = ["22/May", "23/May", "24/May", "25/May", "26/May", "27/May", "28/May", "29/May", "30/May",
                      "31/May", " 1/Jun", " 2/Jun", " 3/Jun", " 4/Jun", " 5/Jun", " 6/Jun", " 7/Jun", " 8/Jun",
                      " 9/Jun", "10/Jun", "11/Jun", "12/Jun", "13/Jun", "14/Jun", "15/Jun", "16/Jun", "17/Jun",
                      "18/Jun", "19/Jun", "20/Jun", "21/Jun", "22/Jun"]

        expect(json['axis']).to eq(axis_dates)
      end

      it "returns month investment data" do
        total_current_values = {
          "22/May" => 2000, "23/May" => 2000, "24/May" => 2000, "25/May" => 2000, "26/May" => 2000,
          "27/May" => 2000, "28/May" => 2000, "29/May" => 2000, "30/May" => 2000, "31/May" => 2000,
          " 1/Jun" => 2000, " 2/Jun" => 2000, " 3/Jun" => 2000, " 4/Jun" => 2000, " 5/Jun" => 2000,
          " 6/Jun" => 2000, " 7/Jun" => 2000, " 8/Jun" => 2000, " 9/Jun" => 2000, "10/Jun" => 2000,
          "11/Jun" => 2000, "12/Jun" => 2000, "13/Jun" => 2000, "14/Jun" => 2000, "15/Jun" => 2000,
          "16/Jun" => 2000, "17/Jun" => 2000, "18/Jun" => 2000, "19/Jun" => 2000, "20/Jun" => 2000,
          "21/Jun" => 2000, "22/Jun" => 2000
        }

        expect(json['total_current_values']).to eq(total_current_values)
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

        post "/auth/login", params: { email: investor.email, password: password}
        token = json['token']

        invested_company1.update_column(:created_at, "20 June 2019")
        invested_company2.update_column(:created_at, "22 June 2019")

        get "/users/#{investor.id}/investor_graphics/total_current_value", headers: { 'Authorization': token }
      end

      it "returns axis and total_current_value" do
        expect(json['axis']).to be_present
        expect(json['total_current_values']).to be_present
      end

      it "returns month axis" do
        axis_dates = ["22/May", "23/May", "24/May", "25/May", "26/May", "27/May", "28/May", "29/May", "30/May",
                      "31/May", " 1/Jun", " 2/Jun", " 3/Jun", " 4/Jun", " 5/Jun", " 6/Jun", " 7/Jun", " 8/Jun",
                      " 9/Jun", "10/Jun", "11/Jun", "12/Jun", "13/Jun", "14/Jun", "15/Jun", "16/Jun", "17/Jun",
                      "18/Jun", "19/Jun", "20/Jun", "21/Jun", "22/Jun"]

        expect(json['axis']).to eq(axis_dates)
      end

      it "returns month investment data" do
        total_current_values = {
          "22/May" => 0, "23/May" => 0, "24/May" => 0, "25/May" => 0, "26/May" => 0,
          "27/May" => 0, "28/May" => 0, "29/May" => 0, "30/May" => 0, "31/May" => 0,
          " 1/Jun" => 0, " 2/Jun" => 0, " 3/Jun" => 0, " 4/Jun" => 0, " 5/Jun" => 0,
          " 6/Jun" => 0, " 7/Jun" => 0, " 8/Jun" => 0, " 9/Jun" => 0, "10/Jun" => 0,
          "11/Jun" => 0, "12/Jun" => 0, "13/Jun" => 0, "14/Jun" => 0, "15/Jun" => 0,
          "16/Jun" => 0, "17/Jun" => 0, "18/Jun" => 0, "19/Jun" => 0, "20/Jun" => 1000,
          "21/Jun" => 1000, "22/Jun" => 2000
        }

        expect(json['total_current_values']).to eq(total_current_values)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      after do
        Timecop.return
      end
    end

    context 'when get without params and get company and invested later than beginning of month' do
      before do
        t = "22 June 2019".to_datetime
        Timecop.freeze(t)

        post "/auth/login", params: { email: investor.email, password: password}
        token = json['token']

        invested_company1.update_column(:created_at, "20 June 2019")
        invested_company2.update_column(:created_at, "22 June 2019")

        get "/users/#{investor.id}/investor_graphics/total_current_value", params: {company_id: company2.id}, headers: { 'Authorization': token }
      end

      it "returns axis and total_current_value" do
        expect(json['axis']).to be_present
        expect(json['total_current_values']).to be_present
      end

      it "returns month axis" do
        axis_dates = ["22/May", "23/May", "24/May", "25/May", "26/May", "27/May", "28/May", "29/May", "30/May",
                      "31/May", " 1/Jun", " 2/Jun", " 3/Jun", " 4/Jun", " 5/Jun", " 6/Jun", " 7/Jun", " 8/Jun",
                      " 9/Jun", "10/Jun", "11/Jun", "12/Jun", "13/Jun", "14/Jun", "15/Jun", "16/Jun", "17/Jun",
                      "18/Jun", "19/Jun", "20/Jun", "21/Jun", "22/Jun"]

        expect(json['axis']).to eq(axis_dates)
      end

      it "returns month investment data" do
        total_current_values = {
          "22/May" => 0, "23/May" => 0, "24/May" => 0, "25/May" => 0, "26/May" => 0,
          "27/May" => 0, "28/May" => 0, "29/May" => 0, "30/May" => 0, "31/May" => 0,
          " 1/Jun" => 0, " 2/Jun" => 0, " 3/Jun" => 0, " 4/Jun" => 0, " 5/Jun" => 0,
          " 6/Jun" => 0, " 7/Jun" => 0, " 8/Jun" => 0, " 9/Jun" => 0, "10/Jun" => 0,
          "11/Jun" => 0, "12/Jun" => 0, "13/Jun" => 0, "14/Jun" => 0, "15/Jun" => 0,
          "16/Jun" => 0, "17/Jun" => 0, "18/Jun" => 0, "19/Jun" => 0, "20/Jun" => 0,
          "21/Jun" => 0, "22/Jun" => 1000
        }

        expect(json['total_current_values']).to eq(total_current_values)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      after do
        Timecop.return
      end
    end

    context 'when get without params and get company and double invested' do
      before do
        t = "22 June 2019".to_datetime
        Timecop.freeze(t)

        post "/auth/login", params: { email: investor.email, password: password}
        token = json['token']

        invested_company1.update_column(:created_at, "20 June 2019")
        invested_company2.update_column(:created_at, "20 June 2019")

        InvestedCompany.create!(
          company_id: company2.id,
          investor_id: investor.id,
          contact_email: company2.contact_email,
          investment: 3000,
          evaluation: 10,
          date_from: "22 June 2019".to_datetime,
          date_to: "22 June 2020".to_datetime
        )

        get "/users/#{investor.id}/investor_graphics/total_current_value", params: {company_id: company2.id}, headers: { 'Authorization': token }
      end

      it "returns axis and total_current_value" do
        expect(json['axis']).to be_present
        expect(json['total_current_values']).to be_present
      end

      it "returns month axis" do
        axis_dates = ["22/May", "23/May", "24/May", "25/May", "26/May", "27/May", "28/May", "29/May", "30/May",
                      "31/May", " 1/Jun", " 2/Jun", " 3/Jun", " 4/Jun", " 5/Jun", " 6/Jun", " 7/Jun", " 8/Jun",
                      " 9/Jun", "10/Jun", "11/Jun", "12/Jun", "13/Jun", "14/Jun", "15/Jun", "16/Jun", "17/Jun",
                      "18/Jun", "19/Jun", "20/Jun", "21/Jun", "22/Jun"]

        expect(json['axis']).to eq(axis_dates)
      end

      it "returns month investment data" do
        total_current_values = {
          "22/May" => 0, "23/May" => 0, "24/May" => 0, "25/May" => 0, "26/May" => 0,
          "27/May" => 0, "28/May" => 0, "29/May" => 0, "30/May" => 0, "31/May" => 0,
          " 1/Jun" => 0, " 2/Jun" => 0, " 3/Jun" => 0, " 4/Jun" => 0, " 5/Jun" => 0,
          " 6/Jun" => 0, " 7/Jun" => 0, " 8/Jun" => 0, " 9/Jun" => 0, "10/Jun" => 0,
          "11/Jun" => 0, "12/Jun" => 0, "13/Jun" => 0, "14/Jun" => 0, "15/Jun" => 0,
          "16/Jun" => 0, "17/Jun" => 0, "18/Jun" => 0, "19/Jun" => 0, "20/Jun" => 1000,
          "21/Jun" => 1000, "22/Jun" => 30000
        }

        expect(json['total_current_values']).to eq(total_current_values)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      after do
        Timecop.return
      end
    end

    context 'when get without params and get company and invested bey another investor' do
      before do
        t = "22 June 2019".to_datetime
        Timecop.freeze(t)

        post "/auth/login", params: { email: investor.email, password: password}
        token = json['token']

        invested_company1.update_column(:created_at, "20 June 2019")
        invested_company2.update_column(:created_at, "20 June 2019")

        InvestedCompany.create!(
          company_id: company2.id,
          investor_id: investor_without_investments.id,
          contact_email: company2.contact_email,
          investment: 3000,
          evaluation: 10,
          date_from: "22 June 2019".to_datetime,
          date_to: "22 June 2020".to_datetime
        )

        get "/users/#{investor.id}/investor_graphics/total_current_value", params: {company_id: company2.id}, headers: { 'Authorization': token }
      end

      it "returns axis and total_current_value" do
        expect(json['axis']).to be_present
        expect(json['total_current_values']).to be_present
      end

      it "returns month axis" do
        axis_dates = ["22/May", "23/May", "24/May", "25/May", "26/May", "27/May", "28/May", "29/May", "30/May",
                      "31/May", " 1/Jun", " 2/Jun", " 3/Jun", " 4/Jun", " 5/Jun", " 6/Jun", " 7/Jun", " 8/Jun",
                      " 9/Jun", "10/Jun", "11/Jun", "12/Jun", "13/Jun", "14/Jun", "15/Jun", "16/Jun", "17/Jun",
                      "18/Jun", "19/Jun", "20/Jun", "21/Jun", "22/Jun"]

        expect(json['axis']).to eq(axis_dates)
      end

      it "returns month investment data" do
        total_current_values = {
          "22/May" => 0, "23/May" => 0, "24/May" => 0, "25/May" => 0, "26/May" => 0,
          "27/May" => 0, "28/May" => 0, "29/May" => 0, "30/May" => 0, "31/May" => 0,
          " 1/Jun" => 0, " 2/Jun" => 0, " 3/Jun" => 0, " 4/Jun" => 0, " 5/Jun" => 0,
          " 6/Jun" => 0, " 7/Jun" => 0, " 8/Jun" => 0, " 9/Jun" => 0, "10/Jun" => 0,
          "11/Jun" => 0, "12/Jun" => 0, "13/Jun" => 0, "14/Jun" => 0, "15/Jun" => 0,
          "16/Jun" => 0, "17/Jun" => 0, "18/Jun" => 0, "19/Jun" => 0, "20/Jun" => 1000,
          "21/Jun" => 1000, "22/Jun" => 30000
        }

        expect(json['total_current_values']).to eq(total_current_values)
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

        post "/auth/login", params: { email: investor.email, password: password}
        token = json['token']

        get "/users/#{investor.id}/investor_graphics/total_current_value", params: {period: "month"}, headers: { 'Authorization': token }
      end

      it "returns axis and total_current_value" do
        expect(json['axis']).to be_present
        expect(json['total_current_values']).to be_present
      end

      it "returns month axis" do
        axis_dates = [" 1/Jan", " 2/Jan", " 3/Jan", " 4/Jan", " 5/Jan", " 6/Jan", " 7/Jan", " 8/Jan", " 9/Jan",
                      "10/Jan", "11/Jan", "12/Jan", "13/Jan", "14/Jan", "15/Jan", "16/Jan", "17/Jan", "18/Jan",
                      "19/Jan", "20/Jan", "21/Jan", "22/Jan", "23/Jan", "24/Jan", "25/Jan", "26/Jan", "27/Jan",
                      "28/Jan", "29/Jan", "30/Jan", "31/Jan", " 1/Feb"]

        expect(json['axis']).to eq(axis_dates)
      end

      it "returns month investment data" do
        total_current_values = {
          " 1/Jan" => 0, " 2/Jan" => 0, " 3/Jan" => 0, " 4/Jan" => 0, " 5/Jan" => 0, " 6/Jan" => 0,
          " 7/Jan" => 0, " 8/Jan" => 0, " 9/Jan" => 0, "10/Jan" => 0, "11/Jan" => 0, "12/Jan" => 0,
          "13/Jan" => 0, "14/Jan" => 0, "15/Jan" => 0, "16/Jan" => 0, "17/Jan" => 0, "18/Jan" => 0,
          "19/Jan" => 0, "20/Jan" => 0, "21/Jan" => 0, "22/Jan" => 0, "23/Jan" => 0, "24/Jan" => 0,
          "25/Jan" => 0, "26/Jan" => 0, "27/Jan" => 0, "28/Jan" => 0, "29/Jan" => 0, "30/Jan" => 0,
          "31/Jan" => 0, " 1/Feb" => 2000
        }

        expect(json['total_current_values']).to eq(total_current_values)
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

        post "/auth/login", params: { email: investor.email, password: password}
        token = json['token']

        get "/users/#{investor.id}/investor_graphics/total_current_value", params: {period: "month"}, headers: { 'Authorization': token }
      end

      it "returns axis and total_current_value" do
        expect(json['axis']).to be_present
        expect(json['total_current_values']).to be_present
      end

      it "returns month axis" do
        axis_dates = ["22/May", "23/May", "24/May", "25/May", "26/May", "27/May", "28/May", "29/May", "30/May",
                      "31/May", " 1/Jun", " 2/Jun", " 3/Jun", " 4/Jun", " 5/Jun", " 6/Jun", " 7/Jun", " 8/Jun",
                      " 9/Jun", "10/Jun", "11/Jun", "12/Jun", "13/Jun", "14/Jun", "15/Jun", "16/Jun", "17/Jun",
                      "18/Jun", "19/Jun", "20/Jun", "21/Jun", "22/Jun"]

        expect(json['axis']).to eq(axis_dates)
      end

      it "returns month investment data" do
        total_current_values = {
          "22/May" => 2000, "23/May" => 2000, "24/May" => 2000, "25/May" => 2000, "26/May" => 2000,
          "27/May" => 2000, "28/May" => 2000, "29/May" => 2000, "30/May" => 2000, "31/May" => 2000,
          " 1/Jun" => 2000, " 2/Jun" => 2000, " 3/Jun" => 2000, " 4/Jun" => 2000, " 5/Jun" => 2000,
          " 6/Jun" => 2000, " 7/Jun" => 2000, " 8/Jun" => 2000, " 9/Jun" => 2000, "10/Jun" => 2000,
          "11/Jun" => 2000, "12/Jun" => 2000, "13/Jun" => 2000, "14/Jun" => 2000, "15/Jun" => 2000,
          "16/Jun" => 2000, "17/Jun" => 2000, "18/Jun" => 2000, "19/Jun" => 2000, "20/Jun" => 2000,
          "21/Jun" => 2000, "22/Jun" => 2000
        }

        expect(json['total_current_values']).to eq(total_current_values)
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

        post "/auth/login", params: { email: investor.email, password: password}
        token = json['token']

        invested_company1.update_column(:created_at, "20 June 2019")
        invested_company2.update_column(:created_at, "22 June 2019")

        get "/users/#{investor.id}/investor_graphics/total_current_value", params: {period: "month"}, headers: { 'Authorization': token }
      end

      it "returns axis and total_current_value" do
        expect(json['axis']).to be_present
        expect(json['total_current_values']).to be_present
      end

      it "returns month axis" do
        axis_dates = ["22/May", "23/May", "24/May", "25/May", "26/May", "27/May", "28/May", "29/May", "30/May",
                      "31/May", " 1/Jun", " 2/Jun", " 3/Jun", " 4/Jun", " 5/Jun", " 6/Jun", " 7/Jun", " 8/Jun",
                      " 9/Jun", "10/Jun", "11/Jun", "12/Jun", "13/Jun", "14/Jun", "15/Jun", "16/Jun", "17/Jun",
                      "18/Jun", "19/Jun", "20/Jun", "21/Jun", "22/Jun"]

        expect(json['axis']).to eq(axis_dates)
      end

      it "returns month investment data" do
        total_current_values = {
          "22/May" => 0, "23/May" => 0, "24/May" => 0, "25/May" => 0, "26/May" => 0,
          "27/May" => 0, "28/May" => 0, "29/May" => 0, "30/May" => 0, "31/May" => 0,
          " 1/Jun" => 0, " 2/Jun" => 0, " 3/Jun" => 0, " 4/Jun" => 0, " 5/Jun" => 0,
          " 6/Jun" => 0, " 7/Jun" => 0, " 8/Jun" => 0, " 9/Jun" => 0, "10/Jun" => 0,
          "11/Jun" => 0, "12/Jun" => 0, "13/Jun" => 0, "14/Jun" => 0, "15/Jun" => 0,
          "16/Jun" => 0, "17/Jun" => 0, "18/Jun" => 0, "19/Jun" => 0, "20/Jun" => 1000,
          "21/Jun" => 1000, "22/Jun" => 2000
        }

        expect(json['total_current_values']).to eq(total_current_values)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      after do
        Timecop.return
      end
    end

    context 'when get by month and company and invested later than beginning of month' do
      before do
        t = "22 June 2019".to_datetime
        Timecop.freeze(t)

        post "/auth/login", params: { email: investor.email, password: password}
        token = json['token']

        invested_company1.update_column(:created_at, "20 June 2019")
        invested_company2.update_column(:created_at, "22 June 2019")

        get "/users/#{investor.id}/investor_graphics/total_current_value", params: {period: "month", company_id: company2.id}, headers: { 'Authorization': token }
      end

      it "returns axis and total_current_value" do
        expect(json['axis']).to be_present
        expect(json['total_current_values']).to be_present
      end

      it "returns month axis" do
        axis_dates = ["22/May", "23/May", "24/May", "25/May", "26/May", "27/May", "28/May", "29/May", "30/May",
                      "31/May", " 1/Jun", " 2/Jun", " 3/Jun", " 4/Jun", " 5/Jun", " 6/Jun", " 7/Jun", " 8/Jun",
                      " 9/Jun", "10/Jun", "11/Jun", "12/Jun", "13/Jun", "14/Jun", "15/Jun", "16/Jun", "17/Jun",
                      "18/Jun", "19/Jun", "20/Jun", "21/Jun", "22/Jun"]

        expect(json['axis']).to eq(axis_dates)
      end

      it "returns month investment data" do
        total_current_values = {
          "22/May" => 0, "23/May" => 0, "24/May" => 0, "25/May" => 0, "26/May" => 0,
          "27/May" => 0, "28/May" => 0, "29/May" => 0, "30/May" => 0, "31/May" => 0,
          " 1/Jun" => 0, " 2/Jun" => 0, " 3/Jun" => 0, " 4/Jun" => 0, " 5/Jun" => 0,
          " 6/Jun" => 0, " 7/Jun" => 0, " 8/Jun" => 0, " 9/Jun" => 0, "10/Jun" => 0,
          "11/Jun" => 0, "12/Jun" => 0, "13/Jun" => 0, "14/Jun" => 0, "15/Jun" => 0,
          "16/Jun" => 0, "17/Jun" => 0, "18/Jun" => 0, "19/Jun" => 0, "20/Jun" => 0,
          "21/Jun" => 0, "22/Jun" => 1000
        }

        expect(json['total_current_values']).to eq(total_current_values)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      after do
        Timecop.return
      end
    end

    context 'when get by month and company and double invested' do
      before do
        t = "22 June 2019".to_datetime
        Timecop.freeze(t)

        post "/auth/login", params: { email: investor.email, password: password}
        token = json['token']

        invested_company1.update_column(:created_at, "20 June 2019")
        invested_company2.update_column(:created_at, "20 June 2019")

        InvestedCompany.create!(
          company_id: company2.id,
          investor_id: investor.id,
          contact_email: company2.contact_email,
          investment: 3000,
          evaluation: 10,
          date_from: "22 June 2019".to_datetime,
          date_to: "22 June 2020".to_datetime
        )

        get "/users/#{investor.id}/investor_graphics/total_current_value", params: {period: "month", company_id: company2.id}, headers: { 'Authorization': token }
      end

      it "returns axis and total_current_value" do
        expect(json['axis']).to be_present
        expect(json['total_current_values']).to be_present
      end

      it "returns month axis" do
        axis_dates = ["22/May", "23/May", "24/May", "25/May", "26/May", "27/May", "28/May", "29/May", "30/May",
                      "31/May", " 1/Jun", " 2/Jun", " 3/Jun", " 4/Jun", " 5/Jun", " 6/Jun", " 7/Jun", " 8/Jun",
                      " 9/Jun", "10/Jun", "11/Jun", "12/Jun", "13/Jun", "14/Jun", "15/Jun", "16/Jun", "17/Jun",
                      "18/Jun", "19/Jun", "20/Jun", "21/Jun", "22/Jun"]

        expect(json['axis']).to eq(axis_dates)
      end

      it "returns month investment data" do
        total_current_values = {
          "22/May" => 0, "23/May" => 0, "24/May" => 0, "25/May" => 0, "26/May" => 0,
          "27/May" => 0, "28/May" => 0, "29/May" => 0, "30/May" => 0, "31/May" => 0,
          " 1/Jun" => 0, " 2/Jun" => 0, " 3/Jun" => 0, " 4/Jun" => 0, " 5/Jun" => 0,
          " 6/Jun" => 0, " 7/Jun" => 0, " 8/Jun" => 0, " 9/Jun" => 0, "10/Jun" => 0,
          "11/Jun" => 0, "12/Jun" => 0, "13/Jun" => 0, "14/Jun" => 0, "15/Jun" => 0,
          "16/Jun" => 0, "17/Jun" => 0, "18/Jun" => 0, "19/Jun" => 0, "20/Jun" => 1000,
          "21/Jun" => 1000, "22/Jun" => 30000
        }

        expect(json['total_current_values']).to eq(total_current_values)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      after do
        Timecop.return
      end
    end

    context 'when get by month and company and doutble invested be another investor' do
      before do
        t = "22 June 2019".to_datetime
        Timecop.freeze(t)

        post "/auth/login", params: { email: investor.email, password: password}
        token = json['token']

        invested_company1.update_column(:created_at, "20 June 2019")
        invested_company2.update_column(:created_at, "20 June 2019")

        InvestedCompany.create!(
          company_id: company2.id,
          investor_id: investor_without_investments.id,
          contact_email: company2.contact_email,
          investment: 3000,
          evaluation: 10,
          date_from: "22 June 2019".to_datetime,
          date_to: "22 June 2020".to_datetime
        )

        get "/users/#{investor.id}/investor_graphics/total_current_value", params: {period: "month", company_id: company2.id}, headers: { 'Authorization': token }
      end

      it "returns axis and total_current_value" do
        expect(json['axis']).to be_present
        expect(json['total_current_values']).to be_present
      end

      it "returns month axis" do
        axis_dates = ["22/May", "23/May", "24/May", "25/May", "26/May", "27/May", "28/May", "29/May", "30/May",
                      "31/May", " 1/Jun", " 2/Jun", " 3/Jun", " 4/Jun", " 5/Jun", " 6/Jun", " 7/Jun", " 8/Jun",
                      " 9/Jun", "10/Jun", "11/Jun", "12/Jun", "13/Jun", "14/Jun", "15/Jun", "16/Jun", "17/Jun",
                      "18/Jun", "19/Jun", "20/Jun", "21/Jun", "22/Jun"]

        expect(json['axis']).to eq(axis_dates)
      end

      it "returns month investment data" do
        total_current_values = {
          "22/May" => 0, "23/May" => 0, "24/May" => 0, "25/May" => 0, "26/May" => 0,
          "27/May" => 0, "28/May" => 0, "29/May" => 0, "30/May" => 0, "31/May" => 0,
          " 1/Jun" => 0, " 2/Jun" => 0, " 3/Jun" => 0, " 4/Jun" => 0, " 5/Jun" => 0,
          " 6/Jun" => 0, " 7/Jun" => 0, " 8/Jun" => 0, " 9/Jun" => 0, "10/Jun" => 0,
          "11/Jun" => 0, "12/Jun" => 0, "13/Jun" => 0, "14/Jun" => 0, "15/Jun" => 0,
          "16/Jun" => 0, "17/Jun" => 0, "18/Jun" => 0, "19/Jun" => 0, "20/Jun" => 1000,
          "21/Jun" => 1000, "22/Jun" => 30000
        }

        expect(json['total_current_values']).to eq(total_current_values)
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

        post "/auth/login", params: { email: investor.email, password: password}
        token = json['token']

        get "/users/#{investor.id}/investor_graphics/total_current_value", params: {period: "year"}, headers: { 'Authorization': token }
      end

      it "returns axis and total_current_value" do
        expect(json['axis']).to be_present
        expect(json['total_current_values']).to be_present
      end

      it "returns month axis" do
        axis_dates = ["Feb/18", "Mar/18", "Apr/18", "May/18", "Jun/18", "Jul/18", "Aug/18", "Sep/18", "Oct/18",
                      "Nov/18", "Dec/18", "Jan/19", "Feb/19"]

        expect(json['axis']).to eq(axis_dates)
      end

      it "returns month investment data" do
        total_current_values = {
          "Feb/18" => 0, "Mar/18" => 0, "Apr/18" => 0, "May/18" => 0, "Jun/18" => 0, "Jul/18" => 0,
          "Aug/18" => 0, "Sep/18" => 0, "Oct/18" => 0, "Nov/18" => 0, "Dec/18" => 0, "Jan/19" => 0,
          "Feb/19" => 2000
        }

        expect(json['total_current_values']).to eq(total_current_values)
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

        post "/auth/login", params: { email: investor.email, password: password}
        token = json['token']

        get "/users/#{investor.id}/investor_graphics/total_current_value", params: {period: "year"}, headers: { 'Authorization': token }
      end

      it "returns axis and total_current_value" do
        expect(json['axis']).to be_present
        expect(json['total_current_values']).to be_present
      end

      it "returns year axis" do
        axis_dates = ["Jun/19", "Jul/19", "Aug/19", "Sep/19", "Oct/19", "Nov/19", "Dec/19", "Jan/20", "Feb/20",
                      "Mar/20", "Apr/20", "May/20", "Jun/20"]

        expect(json['axis']).to eq(axis_dates)
      end

      it "returns year investment data" do
        total_current_values = {
          "Jun/19" => 2000, "Jul/19" => 2000, "Aug/19" => 2000, "Sep/19" => 2000, "Oct/19" => 2000,
          "Nov/19" => 2000, "Dec/19" => 2000, "Jan/20" => 2000, "Feb/20" => 2000, "Mar/20" => 2000,
          "Apr/20" => 2000, "May/20" => 2000, "Jun/20" => 2000
        }

        expect(json['total_current_values']).to eq(total_current_values)
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

        post "/auth/login", params: { email: investor.email, password: password}
        token = json['token']

        invested_company1.update_column(:created_at, "20 July 2019")
        invested_company2.update_column(:created_at, "22 Feb 2020")

        get "/users/#{investor.id}/investor_graphics/total_current_value", params: {period: "year"}, headers: { 'Authorization': token }
      end

      it "returns axis and total_current_value" do
        expect(json['axis']).to be_present
        expect(json['total_current_values']).to be_present
      end

      it "returns month axis" do
        axis_dates = ["Jun/19", "Jul/19", "Aug/19", "Sep/19", "Oct/19", "Nov/19", "Dec/19", "Jan/20", "Feb/20",
                      "Mar/20", "Apr/20", "May/20", "Jun/20"]

        expect(json['axis']).to eq(axis_dates)
      end

      it "returns month investment data" do
        total_current_values = {
          "Jun/19" => 0, "Jul/19" => 1000, "Aug/19" => 1000, "Sep/19" => 1000, "Oct/19" => 1000,
          "Nov/19" => 1000, "Dec/19" => 1000, "Jan/20" => 1000, "Feb/20" => 2000, "Mar/20" => 2000,
          "Apr/20" => 2000, "May/20" => 2000, "Jun/20" => 2000
        }

        expect(json['total_current_values']).to eq(total_current_values)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      after do
        Timecop.return
      end
    end

    context 'when get by year and company and invested later than beginning of year' do
      before do
        t = "22 June 2020".to_datetime
        Timecop.freeze(t)

        post "/auth/login", params: { email: investor.email, password: password}
        token = json['token']

        invested_company1.update_column(:created_at, "20 July 2019")
        invested_company2.update_column(:created_at, "22 Feb 2020")

        get "/users/#{investor.id}/investor_graphics/total_current_value", params: {period: "year", company_id: company2.id}, headers: { 'Authorization': token }
      end

      it "returns axis and total_current_value" do
        expect(json['axis']).to be_present
        expect(json['total_current_values']).to be_present
      end

      it "returns month axis" do
        axis_dates = ["Jun/19", "Jul/19", "Aug/19", "Sep/19", "Oct/19", "Nov/19", "Dec/19", "Jan/20", "Feb/20",
                      "Mar/20", "Apr/20", "May/20", "Jun/20"]

        expect(json['axis']).to eq(axis_dates)
      end

      it "returns month investment data" do
        total_current_values = {
          "Jun/19" => 0, "Jul/19" => 0, "Aug/19" => 0, "Sep/19" => 0, "Oct/19" => 0,
          "Nov/19" => 0, "Dec/19" => 0, "Jan/20" => 0, "Feb/20" => 1000, "Mar/20" => 1000,
          "Apr/20" => 1000, "May/20" => 1000, "Jun/20" => 1000
        }

        expect(json['total_current_values']).to eq(total_current_values)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      after do
        Timecop.return
      end
    end

    context 'when get by year and company and double invested' do
      before do
        t = "22 June 2020".to_datetime
        Timecop.freeze(t)

        post "/auth/login", params: { email: investor.email, password: password}
        token = json['token']

        invested_company1.update_column(:created_at, "20 July 2019")
        invested_company2.update_column(:created_at, "20 Feb 2020")

        InvestedCompany.create!(
          company_id: company2.id,
          investor_id: investor.id,
          contact_email: company2.contact_email,
          investment: 3000,
          evaluation: 10,
          date_from: "22 June 2020".to_datetime,
          date_to: "22 June 2021".to_datetime
        )

        get "/users/#{investor.id}/investor_graphics/total_current_value", params: {period: "year", company_id: company2.id}, headers: { 'Authorization': token }
      end

      it "returns axis and total_current_value" do
        expect(json['axis']).to be_present
        expect(json['total_current_values']).to be_present
      end

      it "returns month axis" do
        axis_dates = ["Jun/19", "Jul/19", "Aug/19", "Sep/19", "Oct/19", "Nov/19", "Dec/19", "Jan/20", "Feb/20",
                      "Mar/20", "Apr/20", "May/20", "Jun/20"]

        expect(json['axis']).to eq(axis_dates)
      end

      it "returns month investment data" do
        total_current_values = {
          "Jun/19" => 0, "Jul/19" => 0, "Aug/19" => 0, "Sep/19" => 0, "Oct/19" => 0,
          "Nov/19" => 0, "Dec/19" => 0, "Jan/20" => 0, "Feb/20" => 1000, "Mar/20" => 1000,
          "Apr/20" => 1000, "May/20" => 1000, "Jun/20" => 30000
        }

        expect(json['total_current_values']).to eq(total_current_values)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      after do
        Timecop.return
      end
    end

    context 'when get by year and company and double invested by another investor' do
      before do
        t = "22 June 2020".to_datetime
        Timecop.freeze(t)

        post "/auth/login", params: { email: investor.email, password: password}
        token = json['token']

        invested_company1.update_column(:created_at, "20 July 2019")
        invested_company2.update_column(:created_at, "22 Feb 2020")

        InvestedCompany.create!(
          company_id: company2.id,
          investor_id: investor_without_investments.id,
          contact_email: company2.contact_email,
          investment: 2000,
          evaluation: 10,
          date_from: "22 June 2020".to_datetime,
          date_to: "22 June 2021".to_datetime
        )

        get "/users/#{investor.id}/investor_graphics/total_current_value", params: {period: "year", company_id: company2.id}, headers: { 'Authorization': token }
      end

      it "returns axis and total_current_value" do
        expect(json['axis']).to be_present
        expect(json['total_current_values']).to be_present
      end

      it "returns month axis" do
        axis_dates = ["Jun/19", "Jul/19", "Aug/19", "Sep/19", "Oct/19", "Nov/19", "Dec/19", "Jan/20", "Feb/20",
                      "Mar/20", "Apr/20", "May/20", "Jun/20"]

        expect(json['axis']).to eq(axis_dates)
      end

      it "returns month investment data" do
        total_current_values = {
          "Jun/19" => 0, "Jul/19" => 0, "Aug/19" => 0, "Sep/19" => 0, "Oct/19" => 0,
          "Nov/19" => 0, "Dec/19" => 0, "Jan/20" => 0, "Feb/20" => 1000, "Mar/20" => 1000,
          "Apr/20" => 1000, "May/20" => 1000, "Jun/20" => 20000
        }

        expect(json['total_current_values']).to eq(total_current_values)
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

        post "/auth/login", params: { email: investor.email, password: password}
        token = json['token']

        get "/users/#{investor.id}/investor_graphics/total_current_value", params: {period: "all"}, headers: { 'Authorization': token }
      end

      it "returns axis and total_current_value" do
        expect(json['axis']).to be_present
        expect(json['total_current_values']).to be_present
      end

      it "returns axis from registration date to now" do
        axis_dates = ["18:00"]

        expect(json['axis']).to eq(axis_dates)
      end

      it "returns year investment data" do
        total_current_values = {"18:00" => 2000}

        expect(json['total_current_values']).to eq(total_current_values)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      after do
        Timecop.return
      end
    end

    context 'when get by all and company and just registered' do
      before do
        t = "2019-02-01T18:23:51.04+03:00".to_datetime
        Timecop.freeze(t)

        post "/auth/login", params: { email: investor.email, password: password}
        token = json['token']

        get "/users/#{investor.id}/investor_graphics/total_current_value", params: {period: "all", company_id: company2.id}, headers: { 'Authorization': token }
      end

      it "returns axis and total_current_value" do
        expect(json['axis']).to be_present
        expect(json['total_current_values']).to be_present
      end

      it "returns axis from registration date to now" do
        axis_dates = ["18:00"]

        expect(json['axis']).to eq(axis_dates)
      end

      it "returns year investment data" do
        total_current_values = {"18:00" => 1000}

        expect(json['total_current_values']).to eq(total_current_values)
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

        post "/auth/login", params: { email: investor.email, password: password}
        token = json['token']

        get "/users/#{investor.id}/investor_graphics/total_current_value", params: {period: "all"}, headers: { 'Authorization': token }
      end

      it "returns axis and total_current_value" do
        expect(json['axis']).to be_present
        expect(json['total_current_values']).to be_present
      end

      it "returns axis from registration date to now" do
        axis_dates = ["18:00", "19:00", "20:00", "21:00", "22:00", "23:00", "00:00", "01:00",
                      "02:00", "03:00", "04:00", "05:00", "06:00"]

        expect(json['axis']).to eq(axis_dates)
      end

      it "returns year investment data" do
        total_current_values = {
          "18:00" => 2000, "19:00" => 2000, "20:00" => 2000, "21:00" => 2000, "22:00" => 2000,
          "23:00" => 2000, "00:00" => 2000, "01:00" => 2000, "02:00" => 2000, "03:00" => 2000,
          "04:00" => 2000, "05:00" => 2000, "06:00" => 2000
        }

        expect(json['total_current_values']).to eq(total_current_values)
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

        post "/auth/login", params: { email: investor.email, password: password}
        token = json['token']

        invested_company1.update_column(:created_at, "2019-02-01T20:23:51.04+03:00".to_datetime)
        invested_company2.update_column(:created_at, "2019-02-02T01:23:51.04+03:00".to_datetime)

        get "/users/#{investor.id}/investor_graphics/total_current_value", params: {period: "all"}, headers: { 'Authorization': token }
      end

      it "returns axis and total_current_value" do
        expect(json['axis']).to be_present
        expect(json['total_current_values']).to be_present
      end

      it "returns axis from registration date to now" do
        axis_dates = ["18:00", "19:00", "20:00", "21:00", "22:00", "23:00", "00:00", "01:00",
                      "02:00", "03:00", "04:00", "05:00", "06:00"]

        expect(json['axis']).to eq(axis_dates)
      end

      it "returns year investment data" do
        total_current_values = {
          "18:00" => 0, "19:00" => 0, "20:00" => 1000, "21:00" => 1000, "22:00" => 1000,
          "23:00" => 1000, "00:00" => 1000, "01:00" => 2000, "02:00" => 2000, "03:00" => 2000,
          "04:00" => 2000, "05:00" => 2000, "06:00" => 2000
        }

        expect(json['total_current_values']).to eq(total_current_values)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      after do
        Timecop.return
      end
    end

    context 'when get by all and company and few hours left and invested in different times' do
      before do
        t = "2019-02-02T06:23:51.04+03:00".to_datetime
        Timecop.freeze(t)

        post "/auth/login", params: { email: investor.email, password: password}
        token = json['token']

        invested_company1.update_column(:created_at, "2019-02-01T20:23:51.04+03:00".to_datetime)
        invested_company2.update_column(:created_at, "2019-02-02T01:23:51.04+03:00".to_datetime)

        get "/users/#{investor.id}/investor_graphics/total_current_value", params: {period: "all", company_id: company2.id}, headers: { 'Authorization': token }
      end

      it "returns axis and total_current_value" do
        expect(json['axis']).to be_present
        expect(json['total_current_values']).to be_present
      end

      it "returns axis from registration date to now" do
        axis_dates = ["18:00", "19:00", "20:00", "21:00", "22:00", "23:00", "00:00", "01:00",
                      "02:00", "03:00", "04:00", "05:00", "06:00"]

        expect(json['axis']).to eq(axis_dates)
      end

      it "returns year investment data" do
        total_current_values = {
          "18:00" => 0, "19:00" => 0, "20:00" => 0, "21:00" => 0, "22:00" => 0,
          "23:00" => 0, "00:00" => 0, "01:00" => 1000, "02:00" => 1000, "03:00" => 1000,
          "04:00" => 1000, "05:00" => 1000, "06:00" => 1000
        }

        expect(json['total_current_values']).to eq(total_current_values)
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

        post "/auth/login", params: { email: investor.email, password: password}
        token = json['token']

        get "/users/#{investor.id}/investor_graphics/total_current_value", params: {period: "all"}, headers: { 'Authorization': token }
      end

      it "returns axis and total_current_value" do
        expect(json['axis']).to be_present
        expect(json['total_current_values']).to be_present
      end

      it "returns axis from registration date to now" do
        axis_dates = [" 1/Feb", " 2/Feb", " 3/Feb", " 4/Feb"]

        expect(json['axis']).to eq(axis_dates)
      end

      it "returns year investment data" do
        total_current_values = {
          " 1/Feb" => 2000, " 2/Feb" => 2000, " 3/Feb" => 2000, " 4/Feb" => 2000
        }

        expect(json['total_current_values']).to eq(total_current_values)
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

        post "/auth/login", params: { email: investor.email, password: password}
        token = json['token']

        invested_company1.update_column(:created_at, "2019-02-02T20:23:51.04+03:00".to_datetime)
        invested_company2.update_column(:created_at, "2019-02-04T01:23:51.04+03:00".to_datetime)

        get "/users/#{investor.id}/investor_graphics/total_current_value", params: {period: "all"}, headers: { 'Authorization': token }
      end

      it "returns axis and total_current_value" do
        expect(json['axis']).to be_present
        expect(json['total_current_values']).to be_present
      end

      it "returns axis from registration date to now" do
        axis_dates = [" 1/Feb", " 2/Feb", " 3/Feb", " 4/Feb"]

        expect(json['axis']).to eq(axis_dates)
      end

      it "returns year investment data" do
        total_current_values = {
          " 1/Feb" => 0, " 2/Feb" => 1000, " 3/Feb" => 1000, " 4/Feb" => 2000
        }

        expect(json['total_current_values']).to eq(total_current_values)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      after do
        Timecop.return
      end
    end

    context 'when get by all and company and few days left and invested in different times' do
      before do
        t = "2019-02-04T06:23:51.04+03:00".to_datetime
        Timecop.freeze(t)

        post "/auth/login", params: { email: investor.email, password: password}
        token = json['token']

        invested_company1.update_column(:created_at, "2019-02-02T20:23:51.04+03:00".to_datetime)
        invested_company2.update_column(:created_at, "2019-02-04T01:23:51.04+03:00".to_datetime)

        get "/users/#{investor.id}/investor_graphics/total_current_value", params: {period: "all", company_id: company2.id}, headers: { 'Authorization': token }
      end

      it "returns axis and total_current_value" do
        expect(json['axis']).to be_present
        expect(json['total_current_values']).to be_present
      end

      it "returns axis from registration date to now" do
        axis_dates = [" 1/Feb", " 2/Feb", " 3/Feb", " 4/Feb"]

        expect(json['axis']).to eq(axis_dates)
      end

      it "returns year investment data" do
        total_current_values = {
          " 1/Feb" => 0, " 2/Feb" => 0, " 3/Feb" => 0, " 4/Feb" => 1000
        }

        expect(json['total_current_values']).to eq(total_current_values)
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

        post "/auth/login", params: { email: investor.email, password: password}
        token = json['token']

        get "/users/#{investor.id}/investor_graphics/total_current_value", params: {period: "all"}, headers: { 'Authorization': token }
      end

      it "returns axis and total_current_value" do
        expect(json['axis']).to be_present
        expect(json['total_current_values']).to be_present
      end

      it "returns axis from registration date to now" do
        axis_dates = [" 1/Feb", " 2/Feb", " 3/Feb", " 4/Feb", " 5/Feb", " 6/Feb", " 7/Feb", " 8/Feb",
                      " 9/Feb", "10/Feb"]

        expect(json['axis']).to eq(axis_dates)
      end

      it "returns year investment data" do
        total_current_values = {
          " 1/Feb" => 2000, " 2/Feb" => 2000, " 3/Feb" => 2000, " 4/Feb" => 2000, " 5/Feb" => 2000,
          " 6/Feb" => 2000, " 7/Feb" => 2000, " 8/Feb" => 2000, " 9/Feb" => 2000, "10/Feb" => 2000
        }

        expect(json['total_current_values']).to eq(total_current_values)
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

        post "/auth/login", params: { email: investor.email, password: password}
        token = json['token']

        invested_company1.update_column(:created_at, "2019-02-02T20:23:51.04+03:00".to_datetime)
        invested_company2.update_column(:created_at, "2019-02-04T01:23:51.04+03:00".to_datetime)

        get "/users/#{investor.id}/investor_graphics/total_current_value", params: {period: "all"}, headers: { 'Authorization': token }
      end

      it "returns axis and total_current_value" do
        expect(json['axis']).to be_present
        expect(json['total_current_values']).to be_present
      end

      it "returns axis from registration date to now" do
        axis_dates = [" 1/Feb", " 2/Feb", " 3/Feb", " 4/Feb", " 5/Feb", " 6/Feb", " 7/Feb", " 8/Feb",
                      " 9/Feb", "10/Feb"]

        expect(json['axis']).to eq(axis_dates)
      end

      it "returns year investment data" do
        total_current_values = {
          " 1/Feb" => 0, " 2/Feb" => 1000, " 3/Feb" => 1000, " 4/Feb" => 2000, " 5/Feb" => 2000,
          " 6/Feb" => 2000, " 7/Feb" => 2000, " 8/Feb" => 2000, " 9/Feb" => 2000, "10/Feb" => 2000
        }

        expect(json['total_current_values']).to eq(total_current_values)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      after do
        Timecop.return
      end
    end

    context 'when get by all and company and few weeks left and invested in different times' do
      before do
        t = "2019-02-10T06:23:51.04+03:00".to_datetime
        Timecop.freeze(t)

        post "/auth/login", params: { email: investor.email, password: password}
        token = json['token']

        invested_company1.update_column(:created_at, "2019-02-02T20:23:51.04+03:00".to_datetime)
        invested_company2.update_column(:created_at, "2019-02-04T01:23:51.04+03:00".to_datetime)

        get "/users/#{investor.id}/investor_graphics/total_current_value", params: {period: "all", company_id: company2.id}, headers: { 'Authorization': token }
      end

      it "returns axis and total_current_value" do
        expect(json['axis']).to be_present
        expect(json['total_current_values']).to be_present
      end

      it "returns axis from registration date to now" do
        axis_dates = [" 1/Feb", " 2/Feb", " 3/Feb", " 4/Feb", " 5/Feb", " 6/Feb", " 7/Feb", " 8/Feb",
                      " 9/Feb", "10/Feb"]

        expect(json['axis']).to eq(axis_dates)
      end

      it "returns year investment data" do
        total_current_values = {
          " 1/Feb" => 0, " 2/Feb" => 0, " 3/Feb" => 0, " 4/Feb" => 1000, " 5/Feb" => 1000,
          " 6/Feb" => 1000, " 7/Feb" =>1000, " 8/Feb" => 1000, " 9/Feb" => 1000, "10/Feb" => 1000
        }

        expect(json['total_current_values']).to eq(total_current_values)
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

        post "/auth/login", params: { email: investor.email, password: password}
        token = json['token']

        get "/users/#{investor.id}/investor_graphics/total_current_value", params: {period: "all"}, headers: { 'Authorization': token }
      end

      it "returns axis and total_current_value" do
        expect(json['axis']).to be_present
        expect(json['total_current_values']).to be_present
      end

      it "returns axis from registration date to now" do
        axis_dates = ["Feb/19", "Mar/19"]

        expect(json['axis']).to eq(axis_dates)
      end

      it "returns year investment data" do
        total_current_values = {
          "Feb/19" => 2000, "Mar/19" => 2000
        }

        expect(json['total_current_values']).to eq(total_current_values)
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

        post "/auth/login", params: { email: investor.email, password: password}
        token = json['token']

        invested_company1.update_column(:created_at, "2019-03-02T20:23:51.04+03:00".to_datetime)
        invested_company2.update_column(:created_at, "2019-05-04T01:23:51.04+03:00".to_datetime)

        get "/users/#{investor.id}/investor_graphics/total_current_value", params: {period: "all"}, headers: { 'Authorization': token }
      end

      it "returns axis and total_current_value" do
        expect(json['axis']).to be_present
        expect(json['total_current_values']).to be_present
      end

      it "returns axis from registration date to now" do
        axis_dates = ["Feb/19", "Mar/19", "Apr/19", "May/19", "Jun/19", "Jul/19"]

        expect(json['axis']).to eq(axis_dates)
      end

      it "returns year investment data" do
        total_current_values = {
          "Feb/19" => 0, "Mar/19" => 1000, "Apr/19" => 1000, "May/19" => 2000, "Jun/19" => 2000, "Jul/19" => 2000
        }

        expect(json['total_current_values']).to eq(total_current_values)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      after do
        Timecop.return
      end
    end

    context 'when get by all and company and few month left and invested in different times' do
      before do
        t = "2019-07-10T06:23:51.04+03:00".to_datetime
        Timecop.freeze(t)

        post "/auth/login", params: { email: investor.email, password: password}
        token = json['token']

        invested_company1.update_column(:created_at, "2019-03-02T20:23:51.04+03:00".to_datetime)
        invested_company2.update_column(:created_at, "2019-05-04T01:23:51.04+03:00".to_datetime)

        get "/users/#{investor.id}/investor_graphics/total_current_value", params: {period: "all", company_id: company2.id}, headers: { 'Authorization': token }
      end

      it "returns axis and total_current_value" do
        expect(json['axis']).to be_present
        expect(json['total_current_values']).to be_present
      end

      it "returns axis from registration date to now" do
        axis_dates = ["Feb/19", "Mar/19", "Apr/19", "May/19", "Jun/19", "Jul/19"]

        expect(json['axis']).to eq(axis_dates)
      end

      it "returns year investment data" do
        total_current_values = {
          "Feb/19" => 0, "Mar/19" => 0, "Apr/19" => 0, "May/19" => 1000, "Jun/19" => 1000, "Jul/19" => 1000
        }

        expect(json['total_current_values']).to eq(total_current_values)
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

        post "/auth/login", params: { email: investor.email, password: password}
        token = json['token']

        get "/users/#{investor.id}/investor_graphics/total_current_value", params: {period: "all"}, headers: { 'Authorization': token }
      end

      it "returns axis and total_current_value" do
        expect(json['axis']).to be_present
        expect(json['total_current_values']).to be_present
      end

      it "returns axis from registration date to now" do
        axis_dates = ["2019", "2020"]

        expect(json['axis']).to eq(axis_dates)
      end

      it "returns year investment data" do
        total_current_values = {
          "2019" => 2000, "2020" => 2000
        }

        expect(json['total_current_values']).to eq(total_current_values)
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

        post "/auth/login", params: { email: investor.email, password: password}
        token = json['token']

        invested_company1.update_column(:created_at, "2020-03-02T20:23:51.04+03:00".to_datetime)
        invested_company2.update_column(:created_at, "2021-05-04T01:23:51.04+03:00".to_datetime)

        get "/users/#{investor.id}/investor_graphics/total_current_value", params: {period: "all"}, headers: { 'Authorization': token }
      end

      it "returns axis and total_current_value" do
        expect(json['axis']).to be_present
        expect(json['total_current_values']).to be_present
      end

      it "returns axis from registration date to now" do
        axis_dates = ["2019", "2020", "2021"]

        expect(json['axis']).to eq(axis_dates)
      end

      it "returns year investment data" do
        total_current_values = {
          "2019" => 0, "2020" => 1000, "2021" => 2000
        }

        expect(json['total_current_values']).to eq(total_current_values)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      after do
        Timecop.return
      end
    end

    context 'when get by all and company and few years left and invested in different times' do
      before do
        t = "2021-07-10T06:23:51.04+03:00".to_datetime
        Timecop.freeze(t)

        post "/auth/login", params: { email: investor.email, password: password}
        token = json['token']

        invested_company1.update_column(:created_at, "2020-03-02T20:23:51.04+03:00".to_datetime)
        invested_company2.update_column(:created_at, "2021-05-04T01:23:51.04+03:00".to_datetime)

        get "/users/#{investor.id}/investor_graphics/total_current_value", params: {period: "all", company_id: company2.id}, headers: { 'Authorization': token }
      end

      it "returns axis and total_current_value" do
        expect(json['axis']).to be_present
        expect(json['total_current_values']).to be_present
      end

      it "returns axis from registration date to now" do
        axis_dates = ["2019", "2020", "2021"]

        expect(json['axis']).to eq(axis_dates)
      end

      it "returns year investment data" do
        total_current_values = {
          "2019" => 0, "2020" => 0, "2021" => 1000
        }

        expect(json['total_current_values']).to eq(total_current_values)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      after do
        Timecop.return
      end
    end

    context 'when get by not invested company' do
      before do
        post "/auth/login", params: { email: investor_without_investments.email, password: password}
        token = json['token']

        get "/users/#{investor_without_investments.id}/investor_graphics/total_current_value", params: {company_id: company.id}, headers: { 'Authorization': token }
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

  # Test suite for GET /users/1/investor_graphics/amount_invested
  describe 'GET /users/1/investor_graphics/amount_invested' do
    context 'when simply get' do
      before do
        post "/auth/login", params: { email: investor.email, password: password}
        token = json['token']

        get "/users/#{investor.id}/investor_graphics/amount_invested", headers: { 'Authorization': token }
      end

      it "returns all investments" do
        expect(json["amount_invested"]).to match(200)
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

    context 'when invested twice' do
      before do
        post "/auth/login", params: { email: investor.email, password: password}
        token = json['token']

        investment = InvestedCompany.new(
          investor_id: investor.id,
          company_id: company.id,
          investment: 100,
          evaluation: 1,
          contact_email: company.contact_email,
          date_from: DateTime.now,
          date_to: DateTime.now.next_year(1))
        investment.save!

        get "/users/#{investor.id}/investor_graphics/amount_invested", params: {company_id: company.id}, headers: { 'Authorization': token }
      end

      it "returns all investments" do
        expect(json["amount_invested"]).to match(200)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when get by not invested company' do
      before do
        post "/auth/login", params: { email: investor_without_investments.email, password: password}
        token = json['token']

        get "/users/#{investor_without_investments.id}/investor_graphics/amount_invested", params: {company_id: company.id}, headers: { 'Authorization': token }
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
  describe 'GET /users/1/investor_graphics/rate_of_return' do
    context 'when get without params when registered' do
      before do
        t = "2019-02-01T18:23:51".to_datetime
        Timecop.freeze(t)

        post "/auth/login", params: { email: investor.email, password: password}
        token = json['token']

        get "/users/#{investor.id}/investor_graphics/rate_of_return", headers: { 'Authorization': token }
      end

      it "returns axis and total_current_value" do
        expect(json['axis']).to be_present
        expect(json['rate_of_return']).to be_present
      end

      it "returns month axis" do
        axis_dates = [" 1/Jan", " 2/Jan", " 3/Jan", " 4/Jan", " 5/Jan", " 6/Jan", " 7/Jan", " 8/Jan", " 9/Jan",
                      "10/Jan", "11/Jan", "12/Jan", "13/Jan", "14/Jan", "15/Jan", "16/Jan", "17/Jan", "18/Jan",
                      "19/Jan", "20/Jan", "21/Jan", "22/Jan", "23/Jan", "24/Jan", "25/Jan", "26/Jan", "27/Jan",
                      "28/Jan", "29/Jan", "30/Jan", "31/Jan", " 1/Feb"]

        expect(json['axis']).to eq(axis_dates)
      end

      it "returns month investment data" do
        # ToDo:
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

        post "/auth/login", params: { email: investor.email, password: password}
        token = json['token']

        get "/users/#{investor.id}/investor_graphics/rate_of_return", headers: { 'Authorization': token }
      end

      it "returns axis and total_current_value" do
        expect(json['axis']).to be_present
        expect(json['rate_of_return']).to be_present
      end

      it "returns month axis" do
        axis_dates = ["22/May", "23/May", "24/May", "25/May", "26/May", "27/May", "28/May", "29/May", "30/May",
                      "31/May", " 1/Jun", " 2/Jun", " 3/Jun", " 4/Jun", " 5/Jun", " 6/Jun", " 7/Jun", " 8/Jun",
                      " 9/Jun", "10/Jun", "11/Jun", "12/Jun", "13/Jun", "14/Jun", "15/Jun", "16/Jun", "17/Jun",
                      "18/Jun", "19/Jun", "20/Jun", "21/Jun", "22/Jun"]

        expect(json['axis']).to eq(axis_dates)
      end

      it "returns month investment data" do
        # ToDo:
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

        post "/auth/login", params: { email: investor.email, password: password}
        token = json['token']

        invested_company1.update_column(:created_at, "20 June 2019")
        invested_company2.update_column(:created_at, "22 June 2019")

        get "/users/#{investor.id}/investor_graphics/rate_of_return", headers: { 'Authorization': token }
      end

      it "returns axis and total_current_value" do
        expect(json['axis']).to be_present
        expect(json['rate_of_return']).to be_present
      end

      it "returns month axis" do
        axis_dates = ["22/May", "23/May", "24/May", "25/May", "26/May", "27/May", "28/May", "29/May", "30/May",
                      "31/May", " 1/Jun", " 2/Jun", " 3/Jun", " 4/Jun", " 5/Jun", " 6/Jun", " 7/Jun", " 8/Jun",
                      " 9/Jun", "10/Jun", "11/Jun", "12/Jun", "13/Jun", "14/Jun", "15/Jun", "16/Jun", "17/Jun",
                      "18/Jun", "19/Jun", "20/Jun", "21/Jun", "22/Jun"]

        expect(json['axis']).to eq(axis_dates)
      end

      it "returns month investment data" do
        # ToDo:
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      after do
        Timecop.return
      end
    end

    context 'when get without params and get company and invested later than beginning of month' do
      before do
        t = "22 June 2019".to_datetime
        Timecop.freeze(t)

        post "/auth/login", params: { email: investor.email, password: password}
        token = json['token']

        invested_company1.update_column(:created_at, "20 June 2019")
        invested_company2.update_column(:created_at, "22 June 2019")

        get "/users/#{investor.id}/investor_graphics/rate_of_return", params: {company_id: company2.id}, headers: { 'Authorization': token }
      end

      it "returns axis and total_current_value" do
        expect(json['axis']).to be_present
        expect(json['rate_of_return']).to be_present
      end

      it "returns month axis" do
        axis_dates = ["22/May", "23/May", "24/May", "25/May", "26/May", "27/May", "28/May", "29/May", "30/May",
                      "31/May", " 1/Jun", " 2/Jun", " 3/Jun", " 4/Jun", " 5/Jun", " 6/Jun", " 7/Jun", " 8/Jun",
                      " 9/Jun", "10/Jun", "11/Jun", "12/Jun", "13/Jun", "14/Jun", "15/Jun", "16/Jun", "17/Jun",
                      "18/Jun", "19/Jun", "20/Jun", "21/Jun", "22/Jun"]

        expect(json['axis']).to eq(axis_dates)
      end

      it "returns month investment data" do
        # ToDo:
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

        post "/auth/login", params: { email: investor.email, password: password}
        token = json['token']

        get "/users/#{investor.id}/investor_graphics/rate_of_return", params: {period: "month"}, headers: { 'Authorization': token }
      end

      it "returns axis and total_current_value" do
        expect(json['axis']).to be_present
        expect(json['rate_of_return']).to be_present
      end

      it "returns month axis" do
        axis_dates = [" 1/Jan", " 2/Jan", " 3/Jan", " 4/Jan", " 5/Jan", " 6/Jan", " 7/Jan", " 8/Jan", " 9/Jan",
                      "10/Jan", "11/Jan", "12/Jan", "13/Jan", "14/Jan", "15/Jan", "16/Jan", "17/Jan", "18/Jan",
                      "19/Jan", "20/Jan", "21/Jan", "22/Jan", "23/Jan", "24/Jan", "25/Jan", "26/Jan", "27/Jan",
                      "28/Jan", "29/Jan", "30/Jan", "31/Jan", " 1/Feb"]

        expect(json['axis']).to eq(axis_dates)
      end

      it "returns month investment data" do
        # ToDo:
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

        post "/auth/login", params: { email: investor.email, password: password}
        token = json['token']

        get "/users/#{investor.id}/investor_graphics/rate_of_return", params: {period: "month"}, headers: { 'Authorization': token }
      end

      it "returns axis and total_current_value" do
        expect(json['axis']).to be_present
        expect(json['rate_of_return']).to be_present
      end

      it "returns month axis" do
        axis_dates = ["22/May", "23/May", "24/May", "25/May", "26/May", "27/May", "28/May", "29/May", "30/May",
                      "31/May", " 1/Jun", " 2/Jun", " 3/Jun", " 4/Jun", " 5/Jun", " 6/Jun", " 7/Jun", " 8/Jun",
                      " 9/Jun", "10/Jun", "11/Jun", "12/Jun", "13/Jun", "14/Jun", "15/Jun", "16/Jun", "17/Jun",
                      "18/Jun", "19/Jun", "20/Jun", "21/Jun", "22/Jun"]

        expect(json['axis']).to eq(axis_dates)
      end

      it "returns month investment data" do
        # ToDo:
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

        post "/auth/login", params: { email: investor.email, password: password}
        token = json['token']

        invested_company1.update_column(:created_at, "20 June 2019")
        invested_company2.update_column(:created_at, "22 June 2019")

        get "/users/#{investor.id}/investor_graphics/rate_of_return", params: {period: "month"}, headers: { 'Authorization': token }
      end

      it "returns axis and total_current_value" do
        expect(json['axis']).to be_present
        expect(json['rate_of_return']).to be_present
      end

      it "returns month axis" do
        axis_dates = ["22/May", "23/May", "24/May", "25/May", "26/May", "27/May", "28/May", "29/May", "30/May",
                      "31/May", " 1/Jun", " 2/Jun", " 3/Jun", " 4/Jun", " 5/Jun", " 6/Jun", " 7/Jun", " 8/Jun",
                      " 9/Jun", "10/Jun", "11/Jun", "12/Jun", "13/Jun", "14/Jun", "15/Jun", "16/Jun", "17/Jun",
                      "18/Jun", "19/Jun", "20/Jun", "21/Jun", "22/Jun"]

        expect(json['axis']).to eq(axis_dates)
      end

      it "returns month investment data" do
        # ToDo:
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      after do
        Timecop.return
      end
    end

    context 'when get by month and company and invested later than beginning of month' do
      before do
        t = "22 June 2019".to_datetime
        Timecop.freeze(t)

        post "/auth/login", params: { email: investor.email, password: password}
        token = json['token']

        invested_company1.update_column(:created_at, "20 June 2019")
        invested_company2.update_column(:created_at, "22 June 2019")

        get "/users/#{investor.id}/investor_graphics/rate_of_return", params: {period: "month", company_id: company2.id}, headers: { 'Authorization': token }
      end

      it "returns axis and total_current_value" do
        expect(json['axis']).to be_present
        expect(json['rate_of_return']).to be_present
      end

      it "returns month axis" do
        axis_dates = ["22/May", "23/May", "24/May", "25/May", "26/May", "27/May", "28/May", "29/May", "30/May",
                      "31/May", " 1/Jun", " 2/Jun", " 3/Jun", " 4/Jun", " 5/Jun", " 6/Jun", " 7/Jun", " 8/Jun",
                      " 9/Jun", "10/Jun", "11/Jun", "12/Jun", "13/Jun", "14/Jun", "15/Jun", "16/Jun", "17/Jun",
                      "18/Jun", "19/Jun", "20/Jun", "21/Jun", "22/Jun"]

        expect(json['axis']).to eq(axis_dates)
      end

      it "returns month investment data" do
        # ToDo:
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

        post "/auth/login", params: { email: investor.email, password: password}
        token = json['token']

        get "/users/#{investor.id}/investor_graphics/rate_of_return", params: {period: "year"}, headers: { 'Authorization': token }
      end

      it "returns axis and total_current_value" do
        expect(json['axis']).to be_present
        expect(json['rate_of_return']).to be_present
      end

      it "returns month axis" do
        axis_dates = ["Feb/18", "Mar/18", "Apr/18", "May/18", "Jun/18", "Jul/18", "Aug/18", "Sep/18", "Oct/18",
                      "Nov/18", "Dec/18", "Jan/19", "Feb/19"]

        expect(json['axis']).to eq(axis_dates)
      end

      it "returns month investment data" do
        # ToDo:
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

        post "/auth/login", params: { email: investor.email, password: password}
        token = json['token']

        get "/users/#{investor.id}/investor_graphics/rate_of_return", params: {period: "year"}, headers: { 'Authorization': token }
      end

      it "returns axis and total_current_value" do
        expect(json['axis']).to be_present
        expect(json['rate_of_return']).to be_present
      end

      it "returns year axis" do
        axis_dates = ["Jun/19", "Jul/19", "Aug/19", "Sep/19", "Oct/19", "Nov/19", "Dec/19", "Jan/20", "Feb/20",
                      "Mar/20", "Apr/20", "May/20", "Jun/20"]

        expect(json['axis']).to eq(axis_dates)
      end

      it "returns year investment data" do
        # ToDo:
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

        post "/auth/login", params: { email: investor.email, password: password}
        token = json['token']

        invested_company1.update_column(:created_at, "20 July 2019")
        invested_company2.update_column(:created_at, "22 Feb 2020")

        get "/users/#{investor.id}/investor_graphics/rate_of_return", params: {period: "year"}, headers: { 'Authorization': token }
      end

      it "returns axis and total_current_value" do
        expect(json['axis']).to be_present
        expect(json['rate_of_return']).to be_present
      end

      it "returns month axis" do
        axis_dates = ["Jun/19", "Jul/19", "Aug/19", "Sep/19", "Oct/19", "Nov/19", "Dec/19", "Jan/20", "Feb/20",
                      "Mar/20", "Apr/20", "May/20", "Jun/20"]

        expect(json['axis']).to eq(axis_dates)
      end

      it "returns month investment data" do
        # ToDo:
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      after do
        Timecop.return
      end
    end

    context 'when get by year and company and invested later than beginning of year' do
      before do
        t = "22 June 2020".to_datetime
        Timecop.freeze(t)

        post "/auth/login", params: { email: investor.email, password: password}
        token = json['token']

        invested_company1.update_column(:created_at, "20 July 2019")
        invested_company2.update_column(:created_at, "22 Feb 2020")

        get "/users/#{investor.id}/investor_graphics/rate_of_return", params: {period: "year", company_id: company2.id}, headers: { 'Authorization': token }
      end

      it "returns axis and total_current_value" do
        expect(json['axis']).to be_present
        expect(json['rate_of_return']).to be_present
      end

      it "returns month axis" do
        axis_dates = ["Jun/19", "Jul/19", "Aug/19", "Sep/19", "Oct/19", "Nov/19", "Dec/19", "Jan/20", "Feb/20",
                      "Mar/20", "Apr/20", "May/20", "Jun/20"]

        expect(json['axis']).to eq(axis_dates)
      end

      it "returns month investment data" do
        # ToDo:
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

        post "/auth/login", params: { email: investor.email, password: password}
        token = json['token']

        get "/users/#{investor.id}/investor_graphics/rate_of_return", params: {period: "all"}, headers: { 'Authorization': token }
      end

      it "returns axis and total_current_value" do
        expect(json['axis']).to be_present
        expect(json['rate_of_return']).to be_present
      end

      it "returns axis from registration date to now" do
        axis_dates = ["18:00"]

        expect(json['axis']).to eq(axis_dates)
      end

      it "returns year investment data" do
        # ToDo:
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      after do
        Timecop.return
      end
    end

    context 'when get by all and company and just registered' do
      before do
        t = "2019-02-01T18:23:51.04+03:00".to_datetime
        Timecop.freeze(t)

        post "/auth/login", params: { email: investor.email, password: password}
        token = json['token']

        get "/users/#{investor.id}/investor_graphics/rate_of_return", params: {period: "all", company_id: company2.id}, headers: { 'Authorization': token }
      end

      it "returns axis and total_current_value" do
        expect(json['axis']).to be_present
        expect(json['rate_of_return']).to be_present
      end

      it "returns axis from registration date to now" do
        axis_dates = ["18:00"]

        expect(json['axis']).to eq(axis_dates)
      end

      it "returns year investment data" do
        # ToDo:
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

        post "/auth/login", params: { email: investor.email, password: password}
        token = json['token']

        get "/users/#{investor.id}/investor_graphics/rate_of_return", params: {period: "all"}, headers: { 'Authorization': token }
      end

      it "returns axis and total_current_value" do
        expect(json['axis']).to be_present
        expect(json['rate_of_return']).to be_present
      end

      it "returns axis from registration date to now" do
        axis_dates = ["18:00", "19:00", "20:00", "21:00", "22:00", "23:00", "00:00", "01:00",
                      "02:00", "03:00", "04:00", "05:00", "06:00"]

        expect(json['axis']).to eq(axis_dates)
      end

      it "returns year investment data" do
        # ToDo:
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

        post "/auth/login", params: { email: investor.email, password: password}
        token = json['token']

        invested_company1.update_column(:created_at, "2019-02-01T20:23:51.04+03:00".to_datetime)
        invested_company2.update_column(:created_at, "2019-02-02T01:23:51.04+03:00".to_datetime)

        get "/users/#{investor.id}/investor_graphics/rate_of_return", params: {period: "all"}, headers: { 'Authorization': token }
      end

      it "returns axis and total_current_value" do
        expect(json['axis']).to be_present
        expect(json['rate_of_return']).to be_present
      end

      it "returns axis from registration date to now" do
        axis_dates = ["18:00", "19:00", "20:00", "21:00", "22:00", "23:00", "00:00", "01:00",
                      "02:00", "03:00", "04:00", "05:00", "06:00"]

        expect(json['axis']).to eq(axis_dates)
      end

      it "returns year investment data" do
        # ToDo:
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      after do
        Timecop.return
      end
    end

    context 'when get by all and company and few hours left and invested in different times' do
      before do
        t = "2019-02-02T06:23:51.04+03:00".to_datetime
        Timecop.freeze(t)

        post "/auth/login", params: { email: investor.email, password: password}
        token = json['token']

        invested_company1.update_column(:created_at, "2019-02-01T20:23:51.04+03:00".to_datetime)
        invested_company2.update_column(:created_at, "2019-02-02T01:23:51.04+03:00".to_datetime)

        get "/users/#{investor.id}/investor_graphics/rate_of_return", params: {period: "all", company_id: company2.id}, headers: { 'Authorization': token }
      end

      it "returns axis and total_current_value" do
        expect(json['axis']).to be_present
        expect(json['rate_of_return']).to be_present
      end

      it "returns axis from registration date to now" do
        axis_dates = ["18:00", "19:00", "20:00", "21:00", "22:00", "23:00", "00:00", "01:00",
                      "02:00", "03:00", "04:00", "05:00", "06:00"]

        expect(json['axis']).to eq(axis_dates)
      end

      it "returns year investment data" do
        # ToDo:
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

        post "/auth/login", params: { email: investor.email, password: password}
        token = json['token']

        get "/users/#{investor.id}/investor_graphics/rate_of_return", params: {period: "all"}, headers: { 'Authorization': token }
      end

      it "returns axis and total_current_value" do
        expect(json['axis']).to be_present
        expect(json['rate_of_return']).to be_present
      end

      it "returns axis from registration date to now" do
        axis_dates = [" 1/Feb", " 2/Feb", " 3/Feb", " 4/Feb"]

        expect(json['axis']).to eq(axis_dates)
      end

      it "returns year investment data" do
        # ToDo:
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

        post "/auth/login", params: { email: investor.email, password: password}
        token = json['token']

        invested_company1.update_column(:created_at, "2019-02-02T20:23:51.04+03:00".to_datetime)
        invested_company2.update_column(:created_at, "2019-02-04T01:23:51.04+03:00".to_datetime)

        get "/users/#{investor.id}/investor_graphics/rate_of_return", params: {period: "all"}, headers: { 'Authorization': token }
      end

      it "returns axis and total_current_value" do
        expect(json['axis']).to be_present
        expect(json['rate_of_return']).to be_present
      end

      it "returns axis from registration date to now" do
        axis_dates = [" 1/Feb", " 2/Feb", " 3/Feb", " 4/Feb"]

        expect(json['axis']).to eq(axis_dates)
      end

      it "returns year investment data" do
        # ToDo:
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      after do
        Timecop.return
      end
    end

    context 'when get by all and company and few days left and invested in different times' do
      before do
        t = "2019-02-04T06:23:51.04+03:00".to_datetime
        Timecop.freeze(t)

        post "/auth/login", params: { email: investor.email, password: password}
        token = json['token']

        invested_company1.update_column(:created_at, "2019-02-02T20:23:51.04+03:00".to_datetime)
        invested_company2.update_column(:created_at, "2019-02-04T01:23:51.04+03:00".to_datetime)

        get "/users/#{investor.id}/investor_graphics/rate_of_return", params: {period: "all", company_id: company2.id}, headers: { 'Authorization': token }
      end

      it "returns axis and total_current_value" do
        expect(json['axis']).to be_present
        expect(json['rate_of_return']).to be_present
      end

      it "returns axis from registration date to now" do
        axis_dates = [" 1/Feb", " 2/Feb", " 3/Feb", " 4/Feb"]

        expect(json['axis']).to eq(axis_dates)
      end

      it "returns year investment data" do
        # ToDo:
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

        post "/auth/login", params: { email: investor.email, password: password}
        token = json['token']

        get "/users/#{investor.id}/investor_graphics/rate_of_return", params: {period: "all"}, headers: { 'Authorization': token }
      end

      it "returns axis and total_current_value" do
        expect(json['axis']).to be_present
        expect(json['rate_of_return']).to be_present
      end

      it "returns axis from registration date to now" do
        axis_dates = [" 1/Feb", " 2/Feb", " 3/Feb", " 4/Feb", " 5/Feb", " 6/Feb", " 7/Feb", " 8/Feb",
                      " 9/Feb", "10/Feb"]

        expect(json['axis']).to eq(axis_dates)
      end

      it "returns year investment data" do
        # ToDo:
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

        post "/auth/login", params: { email: investor.email, password: password}
        token = json['token']

        invested_company1.update_column(:created_at, "2019-02-02T20:23:51.04+03:00".to_datetime)
        invested_company2.update_column(:created_at, "2019-02-04T01:23:51.04+03:00".to_datetime)

        get "/users/#{investor.id}/investor_graphics/rate_of_return", params: {period: "all"}, headers: { 'Authorization': token }
      end

      it "returns axis and total_current_value" do
        expect(json['axis']).to be_present
        expect(json['rate_of_return']).to be_present
      end

      it "returns axis from registration date to now" do
        axis_dates = [" 1/Feb", " 2/Feb", " 3/Feb", " 4/Feb", " 5/Feb", " 6/Feb", " 7/Feb", " 8/Feb",
                      " 9/Feb", "10/Feb"]

        expect(json['axis']).to eq(axis_dates)
      end

      it "returns year investment data" do
        # ToDo:
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      after do
        Timecop.return
      end
    end

    context 'when get by all and company and few weeks left and invested in different times' do
      before do
        t = "2019-02-10T06:23:51.04+03:00".to_datetime
        Timecop.freeze(t)

        post "/auth/login", params: { email: investor.email, password: password}
        token = json['token']

        invested_company1.update_column(:created_at, "2019-02-02T20:23:51.04+03:00".to_datetime)
        invested_company2.update_column(:created_at, "2019-02-04T01:23:51.04+03:00".to_datetime)

        get "/users/#{investor.id}/investor_graphics/rate_of_return", params: {period: "all", company_id: company2.id}, headers: { 'Authorization': token }
      end

      it "returns axis and total_current_value" do
        expect(json['axis']).to be_present
        expect(json['rate_of_return']).to be_present
      end

      it "returns axis from registration date to now" do
        axis_dates = [" 1/Feb", " 2/Feb", " 3/Feb", " 4/Feb", " 5/Feb", " 6/Feb", " 7/Feb", " 8/Feb",
                      " 9/Feb", "10/Feb"]

        expect(json['axis']).to eq(axis_dates)
      end

      it "returns year investment data" do
        # ToDo:
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

        post "/auth/login", params: { email: investor.email, password: password}
        token = json['token']

        get "/users/#{investor.id}/investor_graphics/rate_of_return", params: {period: "all"}, headers: { 'Authorization': token }
      end

      it "returns axis and total_current_value" do
        expect(json['axis']).to be_present
        expect(json['rate_of_return']).to be_present
      end

      it "returns axis from registration date to now" do
        axis_dates = ["Feb/19", "Mar/19"]

        expect(json['axis']).to eq(axis_dates)
      end

      it "returns year investment data" do
        # ToDo:
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

        post "/auth/login", params: { email: investor.email, password: password}
        token = json['token']

        invested_company1.update_column(:created_at, "2019-03-02T20:23:51.04+03:00".to_datetime)
        invested_company2.update_column(:created_at, "2019-05-04T01:23:51.04+03:00".to_datetime)

        get "/users/#{investor.id}/investor_graphics/rate_of_return", params: {period: "all"}, headers: { 'Authorization': token }
      end

      it "returns axis and total_current_value" do
        expect(json['axis']).to be_present
        expect(json['rate_of_return']).to be_present
      end

      it "returns axis from registration date to now" do
        axis_dates = ["Feb/19", "Mar/19", "Apr/19", "May/19", "Jun/19", "Jul/19"]

        expect(json['axis']).to eq(axis_dates)
      end

      it "returns year investment data" do
        # ToDo:
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      after do
        Timecop.return
      end
    end

    context 'when get by all and company and few month left and invested in different times' do
      before do
        t = "2019-07-10T06:23:51.04+03:00".to_datetime
        Timecop.freeze(t)

        post "/auth/login", params: { email: investor.email, password: password}
        token = json['token']

        invested_company1.update_column(:created_at, "2019-03-02T20:23:51.04+03:00".to_datetime)
        invested_company2.update_column(:created_at, "2019-05-04T01:23:51.04+03:00".to_datetime)

        get "/users/#{investor.id}/investor_graphics/rate_of_return", params: {period: "all", company_id: company2.id}, headers: { 'Authorization': token }
      end

      it "returns axis and total_current_value" do
        expect(json['axis']).to be_present
        expect(json['rate_of_return']).to be_present
      end

      it "returns axis from registration date to now" do
        axis_dates = ["Feb/19", "Mar/19", "Apr/19", "May/19", "Jun/19", "Jul/19"]

        expect(json['axis']).to eq(axis_dates)
      end

      it "returns year investment data" do
        # ToDo:
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

        post "/auth/login", params: { email: investor.email, password: password}
        token = json['token']

        get "/users/#{investor.id}/investor_graphics/rate_of_return", params: {period: "all"}, headers: { 'Authorization': token }
      end

      it "returns axis and total_current_value" do
        expect(json['axis']).to be_present
        expect(json['rate_of_return']).to be_present
      end

      it "returns axis from registration date to now" do
        axis_dates = ["2019", "2020"]

        expect(json['axis']).to eq(axis_dates)
      end

      it "returns year investment data" do
        # ToDo:
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

        post "/auth/login", params: { email: investor.email, password: password}
        token = json['token']

        invested_company1.update_column(:created_at, "2020-03-02T20:23:51.04+03:00".to_datetime)
        invested_company2.update_column(:created_at, "2021-05-04T01:23:51.04+03:00".to_datetime)

        get "/users/#{investor.id}/investor_graphics/rate_of_return", params: {period: "all"}, headers: { 'Authorization': token }
      end

      it "returns axis and total_current_value" do
        expect(json['axis']).to be_present
        expect(json['rate_of_return']).to be_present
      end

      it "returns axis from registration date to now" do
        axis_dates = ["2019", "2020", "2021"]

        expect(json['axis']).to eq(axis_dates)
      end

      it "returns year investment data" do
        # ToDo:
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      after do
        Timecop.return
      end
    end

    context 'when get by all and company and few years left and invested in different times' do
      before do
        t = "2021-07-10T06:23:51.04+03:00".to_datetime
        Timecop.freeze(t)

        post "/auth/login", params: { email: investor.email, password: password}
        token = json['token']

        invested_company1.update_column(:created_at, "2020-03-02T20:23:51.04+03:00".to_datetime)
        invested_company2.update_column(:created_at, "2021-05-04T01:23:51.04+03:00".to_datetime)

        get "/users/#{investor.id}/investor_graphics/rate_of_return", params: {period: "all", company_id: company2.id}, headers: { 'Authorization': token }
      end

      it "returns axis and total_current_value" do
        expect(json['axis']).to be_present
        expect(json['rate_of_return']).to be_present
      end

      it "returns axis from registration date to now" do
        axis_dates = ["2019", "2020", "2021"]

        expect(json['axis']).to eq(axis_dates)
      end

      it "returns year investment data" do
        # ToDo:
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      after do
        Timecop.return
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
end

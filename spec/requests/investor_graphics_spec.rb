require 'rails_helper'

RSpec.describe "InvestorGraphicsSpec", type: :request do
  let(:password) { "123123" }
  let!(:user)  { create(:user, password: password, password_confirmation: password, role: :startup) }
  let!(:company) { create(:company, user_id: user.id, created_at: DateTime.now - 1.year) }

  let!(:user2)  { create(:user, password: password, password_confirmation: password, role: :startup) }
  let!(:company2) { create(:company, user_id: user2.id, created_at: DateTime.now - 1.year) }

  let!(:user3)  { create(:user, password: password, password_confirmation: password, role: :startup) }
  let!(:company3) { create(:company, user_id: user3.id, created_at: DateTime.now - 1.year) }

  let!(:investor) { create(:user, password: password, password_confirmation: password, role: :investor, created_at: DateTime.now - 1.year - 1.month )}
  let!(:invested_company_year_ago) { create(:invested_company, investment: 100, evaluation: 10,
                                   company_id: company.id, investor_id: investor.id,
                                   created_at: DateTime.now.prev_year )}
  let!(:invested_company_month_ago) { create(:invested_company, investment: 100, evaluation: 10,
                                   company_id: company2.id, investor_id: investor.id,
                                   created_at: DateTime.now.prev_month )}
  let!(:invested_company_day_ago) { create(:invested_company, investment: 100, evaluation: 10,
                                   company_id: company3.id, investor_id: investor.id,
                                   created_at: DateTime.now.prev_day )}

  let!(:investor_invested_today) { create(:user, password: password, password_confirmation: password, role: :investor)}
  let!(:invested_company) { create(:invested_company, investment: 100, evaluation: 10,
                                            company_id: company.id, investor_id: investor_invested_today.id)}
  
  let!(:investor_without_investments) { create(:user, password: password, password_confirmation: password, role: :investor )}


  # Test suite for GET /users/1/investor_graphics/total_current_value
  describe 'GET /users/1/investor_graphics/total_current_value' do
    context 'when simply get' do
      before do
        post "/auth/login", params: { email: investor.email, password: password}
        token = json['token']

        get "/users/#{investor.id}/investor_graphics/total_current_value", headers: { 'Authorization': token }
      end

      it "returns axis and total_current_value" do
        expect(json['axis']).to be_present
        expect(json['total_current_values']).to be_present
      end

      it "returns month axis" do
        axis_dates = []
        date_range = (DateTime.now - 1.month)..DateTime.now

        date = date_range.first
        while date.in? date_range do
          axis_dates.push(date.strftime("%e/%b"))
          date = date.next_day(1)
        end

        expect(json['axis']).to eq(axis_dates)
      end

      it "returns month investment data" do
        total_current_values = {}
        date_range = (DateTime.now - 1.month)..DateTime.now

        date = date_range.first
        while date.in? date_range do
          date_str = date.strftime("%e/%b")
          date_end = date.end_of_day

          total_current_values[date_str] = 0

          if Time.at(invested_company_year_ago.created_at).to_datetime <= date_end
            total_current_values[date_str] += invested_company_year_ago.company.get_evaluation_on_date(
              invested_company_year_ago.created_at, date_end)
          end
          if Time.at(invested_company_month_ago.created_at).to_datetime <= date_end
            total_current_values[date_str] += invested_company_month_ago.company.get_evaluation_on_date(
              invested_company_month_ago.created_at, date_end)
          end
          if Time.at(invested_company_day_ago.created_at).to_datetime <= date_end
            total_current_values[date_str] += invested_company_day_ago.company.get_evaluation_on_date(
              invested_company_day_ago.created_at, date_end)
          end

          date = date.next_day(1)
        end

        expect(json['total_current_values']).to eq(total_current_values)
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

      it "returns axis and total_current_value" do
        expect(json['axis']).to be_present
        expect(json['total_current_values']).to be_present
      end

      it "returns month axis" do
        axis_dates = []
        date_range = (DateTime.now - 1.month)..DateTime.now

        date = date_range.first
        while date.in? date_range do
          axis_dates.push(date.strftime("%e/%b"))
          date = date.next_day(1)
        end

        expect(json['axis']).to eq(axis_dates)
      end

      it "returns month investment data" do
        total_current_values = {}
        date_range = (DateTime.now - 1.month)..DateTime.now

        date = date_range.first
        while date.in? date_range do
          date_str = date.strftime("%e/%b")
          date_end = date.end_of_day

          total_current_values[date_str] = 0

          if Time.at(invested_company_year_ago.created_at).to_datetime <= date_end
            total_current_values[date_str] += invested_company_year_ago.company.get_evaluation_on_date(
              invested_company_year_ago.created_at, date_end)
          end
          if Time.at(invested_company_month_ago.created_at).to_datetime <= date_end
            total_current_values[date_str] += invested_company_month_ago.company.get_evaluation_on_date(
              invested_company_month_ago.created_at, date_end)
          end
          if Time.at(invested_company_day_ago.created_at).to_datetime <= date.end_of_day
            total_current_values[date_str] += invested_company_day_ago.company.get_evaluation_on_date(
              invested_company_day_ago.created_at, date_end)
          end

          date = date.next_day(1)
        end

        expect(json['total_current_values']).to eq(total_current_values)
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

      it "returns axis and total_current_value" do
        expect(json['axis']).to be_present
        expect(json['total_current_values']).to be_present
      end

      it "returns year axis" do
        axis_dates = []
        date_range = (DateTime.now - 1.year)..DateTime.now

        date = date_range.first
        while date.in? date_range do
          axis_dates.push(date.strftime("%b/%y"))
          date = date.next_month(1)
        end

        expect(json['axis']).to eq(axis_dates)
      end

      it "returns year investment data" do
        total_current_values = {}
        date_range = (DateTime.now - 1.year)..DateTime.now

        date = date_range.first
        while date.in? date_range do
          date_str = date.strftime("%b/%y")
          date_end = date.end_of_month

          total_current_values[date_str] = 0

          if Time.at(invested_company_year_ago.created_at).to_datetime <= date_end
            total_current_values[date_str] += invested_company_year_ago.company.get_evaluation_on_date(
              invested_company_year_ago.created_at, date_end)
          end
          if Time.at(invested_company_month_ago.created_at).to_datetime <= date_end
            total_current_values[date_str] += invested_company_month_ago.company.get_evaluation_on_date(
              invested_company_month_ago.created_at, date_end)
          end
          if Time.at(invested_company_day_ago.created_at).to_datetime <= date_end
            total_current_values[date_str] += invested_company_day_ago.company.get_evaluation_on_date(
              invested_company_day_ago.created_at, date_end)
          end

          date = date.next_month(1)
        end

        expect(json['total_current_values']).to eq(total_current_values)
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

      it "returns axis and total_current_value" do
        expect(json['axis']).to be_present
        expect(json['total_current_values']).to be_present
      end

      it "returns axis from registration date to now" do
        axis_dates = []
        date_range = Time.at(investor.created_at).to_datetime..DateTime.now.end_of_month

        date = date_range.first
        while date.in? date_range do
          axis_dates.push(date.strftime("%b/%y"))
          date = date.next_month(1)
        end

        expect(json['axis']).to eq(axis_dates)
      end

      it "returns year investment data" do
        total_current_values = {}
        date_range = Time.at(investor.created_at).to_datetime..DateTime.now.end_of_month

        date = date_range.first
        while date.in? date_range do
          date_str = date.strftime("%b/%y")
          date_end = date.end_of_month

          total_current_values[date_str] = 0

          if Time.at(invested_company_year_ago.created_at).to_datetime <= date_end
            total_current_values[date_str] += invested_company_year_ago.company.get_evaluation_on_date(
              invested_company_year_ago.created_at, date_end)
          end
          if Time.at(invested_company_month_ago.created_at).to_datetime <= date_end
            total_current_values[date_str] += invested_company_month_ago.company.get_evaluation_on_date(
              invested_company_month_ago.created_at, date_end)
          end
          if Time.at(invested_company_day_ago.created_at).to_datetime <= date_end
            total_current_values[date_str] += invested_company_day_ago.company.get_evaluation_on_date(
              invested_company_day_ago.created_at, date_end)
          end

          date = date.next_month(1)
        end

        expect(json['total_current_values']).to eq(total_current_values)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when get by all and created today' do
      before do
        post "/auth/login", params: { email: investor_invested_today.email, password: password}
        token = json['token']

        get "/users/#{investor_invested_today.id}/investor_graphics/total_current_value", params: {period: "all"}, headers: { 'Authorization': token }
      end

      it "returns axis and total_current_value" do
        expect(json['axis']).to be_present
        expect(json['total_current_values']).to be_present
      end

      it "returns axis from registration date to now" do
        axis_dates = []
        date_range = Time.at(investor_invested_today.created_at).to_datetime..DateTime.now

        date = date_range.first
        while date.in? date_range do
          axis_dates.push(date.strftime("%H"))
          date += 1.hour
        end

        expect(json['axis']).to eq(axis_dates)
      end

      it "returns year investment data" do
        total_current_values = {}
        date_range = Time.at(investor_invested_today.created_at).to_datetime..DateTime.now

        date = date_range.first
        while date.in? date_range do
          date_str = date.strftime("%H")
          date_end = date.end_of_hour

          total_current_values[date_str] = 0

          if Time.at(invested_company.created_at).to_datetime <= date_end
            total_current_values[date_str] += invested_company.company.get_evaluation_on_date(
              invested_company_year_ago.created_at, date_end)
          end

          date += 1.hour
        end

        expect(json['total_current_values']).to eq(total_current_values)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when get by all and created week ago' do
      before do
        post "/auth/login", params: { email: investor_invested_today.email, password: password}
        token = json['token']

        investor_invested_today.created_at = DateTime.now - 1.week
        investor_invested_today.password = password
        investor_invested_today.password_confirmation = password
        investor_invested_today.old_password = password
        investor_invested_today.save!

        get "/users/#{investor_invested_today.id}/investor_graphics/total_current_value", params: {period: "all"}, headers: { 'Authorization': token }
      end

      it "returns axis and total_current_value" do
        expect(json['axis']).to be_present
        expect(json['total_current_values']).to be_present
      end

      it "returns axis from registration date to now" do
        axis_dates = []
        date_range = Time.at(investor_invested_today.created_at).to_datetime..DateTime.now

        date = date_range.first
        while date.in? date_range do
          axis_dates.push(date.strftime("%e/%b"))
          date = date.next_day(1)
        end

        expect(json['axis']).to eq(axis_dates)
      end

      it "returns year investment data" do
        total_current_values = {}
        date_range = Time.at(investor_invested_today.created_at).to_datetime..DateTime.now

        date = date_range.first
        while date.in? date_range do
          date_str = date.strftime("%e/%b")
          date_end = date.end_of_day

          total_current_values[date_str] = 0

          if Time.at(invested_company.created_at).to_datetime <= date_end
            total_current_values[date_str] += invested_company.company.get_evaluation_on_date(
              invested_company.created_at, date_end)
          end

          date = date.next_day(1)
        end

        expect(json['total_current_values']).to eq(total_current_values)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when get by all and created month ago' do
      before do
        post "/auth/login", params: { email: investor_invested_today.email, password: password}
        token = json['token']

        investor_invested_today.created_at = DateTime.now - 1.month
        investor_invested_today.password = password
        investor_invested_today.password_confirmation = password
        investor_invested_today.old_password = password
        investor_invested_today.save!

        get "/users/#{investor_invested_today.id}/investor_graphics/total_current_value", params: {period: "all"}, headers: { 'Authorization': token }
      end

      it "returns axis and total_current_value" do
        expect(json['axis']).to be_present
        expect(json['total_current_values']).to be_present
      end

      it "returns axis from registration date to now" do
        axis_dates = []
        date_range = Time.at(investor_invested_today.created_at).to_datetime..DateTime.now

        date = date_range.first
        while date.in? date_range do
          axis_dates.push(date.strftime("%b/%y"))
          date = date.next_month(1)
        end
        expect(json['axis']).to eq(axis_dates)
      end

      it "returns year investment data" do
        total_current_values = {}
        date_range = Time.at(investor_invested_today.created_at).to_datetime..DateTime.now

        date = date_range.first
        while date.in? date_range do
          date_str = date.strftime("%b/%y")
          date_end = date.end_of_month

          total_current_values[date_str] = 0

          if Time.at(invested_company.created_at).to_datetime <= date_end
            total_current_values[date_str] += invested_company.company.get_evaluation_on_date(
              invested_company_year_ago.created_at, date_end)
          end

          date = date.next_month(1)
        end

        expect(json['total_current_values']).to eq(total_current_values)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when get by invested company' do
      before do
        post "/auth/login", params: { email: investor.email, password: password}
        token = json['token']

        get "/users/#{investor.id}/investor_graphics/total_current_value", params: {company_id: company3.id}, headers: { 'Authorization': token }
      end

      it "returns axis and total_current_value" do
        expect(json['axis']).to be_present
        expect(json['total_current_values']).to be_present
      end

      it "returns month axis" do
        axis_dates = []
        date_range = (DateTime.now - 1.month)..DateTime.now

        date = date_range.first
        while date.in? date_range do
          axis_dates.push(date.strftime("%e/%b"))
          date = date.next_day(1)
        end

        expect(json['axis']).to eq(axis_dates)
      end

      it "returns month investment data" do
        total_current_values = {}
        date_range = (DateTime.now - 1.month)..DateTime.now

        date = date_range.first
        while date.in? date_range do
          date_str = date.strftime("%e/%b")
          date_end = date.end_of_day

          total_current_values[date_str] = 0

          if Time.at(invested_company_day_ago.created_at).to_datetime <= date_end
            total_current_values[date_str] += invested_company_day_ago.company.get_evaluation_on_date(
              invested_company_day_ago.created_at, date_end)
          end

          date = date.next_day(1)
        end

        expect(json['total_current_values']).to eq(total_current_values)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when get by invested company and month' do
      before do
        post "/auth/login", params: { email: investor.email, password: password}
        token = json['token']

        get "/users/#{investor.id}/investor_graphics/total_current_value", params: {company_id: company3.id, period: "month"}, headers: { 'Authorization': token }
      end

      it "returns axis and total_current_value" do
        expect(json['axis']).to be_present
        expect(json['total_current_values']).to be_present
      end

      it "returns month axis" do
        axis_dates = []
        date_range = (DateTime.now - 1.month)..DateTime.now

        date = date_range.first
        while date.in? date_range do
          axis_dates.push(date.strftime("%e/%b"))
          date = date.next_day(1)
        end

        expect(json['axis']).to eq(axis_dates)
      end

      it "returns month investment data" do
        total_current_values = {}
        date_range = (DateTime.now - 1.month)..DateTime.now

        date = date_range.first
        while date.in? date_range do
          date_str = date.strftime("%e/%b")
          date_end = date.end_of_day

          total_current_values[date_str] = 0

          if Time.at(invested_company_day_ago.created_at).to_datetime <= date_end
            total_current_values[date_str] += invested_company_day_ago.company.get_evaluation_on_date(
              invested_company_day_ago.created_at, date_end)
          end

          date = date.next_day(1)
        end

        expect(json['total_current_values']).to eq(total_current_values)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when get by invested company and year' do
      before do
        post "/auth/login", params: { email: investor.email, password: password}
        token = json['token']

        get "/users/#{investor.id}/investor_graphics/total_current_value", params: {company_id: company3.id, period: "year"}, headers: { 'Authorization': token }
      end

      it "returns axis and total_current_value" do
        expect(json['axis']).to be_present
        expect(json['total_current_values']).to be_present
      end

      it "returns year axis" do
        axis_dates = []
        date_range = (DateTime.now - 1.year)..DateTime.now

        date = date_range.first
        while date.in? date_range do
          axis_dates.push(date.strftime("%b/%y"))
          date = date.next_month(1)
        end

        expect(json['axis']).to eq(axis_dates)
      end

      it "returns month investment data" do
        total_current_values = {}
        date_range = (DateTime.now - 1.year)..DateTime.now

        date = date_range.first
        while date.in? date_range do
          date_str = date.strftime("%b/%y")
          date_end = date.end_of_month

          total_current_values[date_str] = 0

          if Time.at(invested_company_day_ago.created_at).to_datetime <= date_end
            total_current_values[date_str] += invested_company_day_ago.company.get_evaluation_on_date(
              invested_company_day_ago.created_at, date_end)
          end

          date = date.next_month(1)
        end

        expect(json['total_current_values']).to eq(total_current_values)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when get by invested company and all' do
      before do
        post "/auth/login", params: { email: investor.email, password: password}
        token = json['token']

        get "/users/#{investor.id}/investor_graphics/total_current_value", params: {company_id: company3.id, period: "all"}, headers: { 'Authorization': token }
      end

      it "returns axis and total_current_value" do
        expect(json['axis']).to be_present
        expect(json['total_current_values']).to be_present
      end

      it "returns axis from registration date" do
        axis_dates = []
        date_range = Time.at(investor.created_at).to_datetime..DateTime.now

        date = date_range.first
        while date.in? date_range do
          axis_dates.push(date.strftime("%b/%y"))
          date = date.next_month(1)
        end

        expect(json['axis']).to eq(axis_dates)
      end

      it "returns month investment data" do
        total_current_values = {}
        date_range = Time.at(investor.created_at).to_datetime..DateTime.now

        date = date_range.first
        while date.in? date_range do
          date_str = date.strftime("%b/%y")
          date_end = date.end_of_month

          total_current_values[date_str] = 0

          if Time.at(invested_company_day_ago.created_at).to_datetime <= date_end
            total_current_values[date_str] += invested_company_day_ago.company.get_evaluation_on_date(
              invested_company_day_ago.created_at, date_end)
          end

          date = date.next_month(1)
        end

        expect(json['total_current_values']).to eq(total_current_values)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
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
        expect(json["amount_invested"]).to match(300)
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
          contact_email: company.contact_email)
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

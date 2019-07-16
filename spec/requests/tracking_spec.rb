require 'rails_helper'

RSpec.describe "TrackingSpec", type: :request do
  let(:password) {"123123"}
  let!(:user) {create(:user, password: password, password_confirmation: password, role: :startup)}
  let!(:company) {create(:company, user_id: user.id, created_at: "2019-02-01T18:23:51.04+03:00".to_datetime)}
  let!(:company_item) {create(:company_item, company_id: company.id)}

  let!(:user2) {create(:user, password: password, password_confirmation: password, role: :startup)}
  let!(:company2) {create(:company, user_id: user2.id)}

  let!(:user3) {create(:user, password: password, password_confirmation: password, role: :startup)}
  let!(:company3) {create(:company, user_id: user3.id)}

  let!(:investor) {create(:user, password: password, password_confirmation: password, role: :investor)}
  let!(:invested_company) {create(:invested_company, investment: 10000, evaluation: 10, company_id: company.id,
                                  investor_id: investor.id)}
  let!(:invested_company3) {create(:invested_company, investment: 10000, evaluation: 10, company_id: company2.id,
                                   investor_id: investor.id)}

  let!(:investor2) {create(:user, password: password, password_confirmation: password, role: :investor)}
  let!(:invested_company2) {create(:invested_company, investment: 10000, evaluation: 10, company_id: company.id,
                                   investor_id: investor2.id)}


  # Test suite for GET /tracking/startup
  describe 'GET /tracking/startup' do
    context 'when simply get' do
      before do
        t = "2019-02-10T06:23:51.04+03:00".to_datetime
        Timecop.freeze(t)

        invested_company.date_from = "2019-02-11"
        invested_company.date_to = "2019-11-11"
        invested_company.save!

        t = "2019-03-10T06:23:51.04+03:00".to_datetime
        Timecop.freeze(t)

        invested_company2.date_from = "2019-03-11"
        invested_company2.date_to = "2019-12-11"
        invested_company2.save!

        InvestmentPayed.create!(
          invested_company: invested_company2,
          date: "2019-03-11",
          amount: 1000
        )

        post "/auth/login", params: {email: user.email, password: password}
        token = json['token']

        get "/tracking/startup", headers: {'Authorization': token}
      end

      it "returns axis and data" do
        expect(json['axis']).to be_present
        expect(json['investors']).to be_present
      end

      it "returns axis from registration date to now" do
        axis_dates = ["Jan/19", "Feb/19", "Mar/19", "Apr/19", "May/19"]

        expect(json['axis']).to eq(axis_dates)
      end

      it "returns year investment data" do
        data = [
          {
            "#{investor.name} #{investor.surname}" => {
              "Jan/19" => {"amount" => 0, "payed" => false},
              "Feb/19" => {"amount" => 1000, "payed" => false},
              "Mar/19" => {"amount" => 1000, "payed" => false},
              "Apr/19" => {"amount" => 1000, "payed" => false},
              "May/19" => {"amount" => 1000, "payed" => false},
              "total_investment" => 10000, "debt" => 10000
            }
          },
          {
            "#{investor2.name} #{investor2.surname}" => {
              "Jan/19" => {"amount" => 0, "payed" => false},
              "Feb/19" => {"amount" => 0, "payed" => false},
              "Mar/19" => {"amount" => 1000, "payed" => true},
              "Apr/19" => {"amount" => 1000, "payed" => false},
              "May/19" => {"amount" => 1000, "payed" => false},
              "total_investment" => 10000, "debt" => 9000
            }
          }
        ]

        expect(json['investors']).to eq(data)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      after do
        Timecop.return
      end
    end

    context 'when in the middle of period' do
      before do
        t = "2019-02-10T06:23:51.04+03:00".to_datetime
        Timecop.freeze(t)

        invested_company.date_from = "2019-02-11"
        invested_company.date_to = "2019-11-11"
        invested_company.save!

        t = "2019-03-10T06:23:51.04+03:00".to_datetime
        Timecop.freeze(t)

        invested_company2.date_from = "2019-03-11"
        invested_company2.date_to = "2019-12-11"
        invested_company2.save!

        ["2019-03-11", "2019-04-11", "2019-05-11", "2019-06-11", "2019-07-11", "2019-08-11", "2019-09-11"].each do |date|
          t = date.to_datetime
          Timecop.freeze(t)

          InvestmentPayed.create!(
            invested_company: invested_company2,
            date: date,
            amount: 1000
          )
        end

        t = "2019-09-10T06:23:51.04+03:00".to_datetime
        Timecop.freeze(t)

        post "/auth/login", params: {email: user.email, password: password}
        token = json['token']

        get "/tracking/startup", headers: {'Authorization': token}
      end

      it "returns axis and data" do
        expect(json['axis']).to be_present
        expect(json['investors']).to be_present
      end

      it "returns axis from registration date to now" do
        axis_dates = ["Jul/19", "Aug/19", "Sep/19", "Oct/19", "Nov/19"]

        expect(json['axis']).to eq(axis_dates)
      end

      it "returns year investment data" do
        data = [
          {
            "#{investor.name} #{investor.surname}" => {
              "Jul/19" => {"amount" => 1000, "payed" => false},
              "Aug/19" => {"amount" => 1000, "payed" => false},
              "Sep/19" => {"amount" => 1000, "payed" => false},
              "Oct/19" => {"amount" => 1000, "payed" => false},
              "Nov/19" => {"amount" => 1000, "payed" => false},
              "total_investment" => 10000, "debt" => 10000
            }
          },
          {
            "#{investor2.name} #{investor2.surname}" => {
              "Jul/19" => {"amount" => 1000, "payed" => true},
              "Aug/19" => {"amount" => 1000, "payed" => true},
              "Sep/19" => {"amount" => 1000, "payed" => true},
              "Oct/19" => {"amount" => 1000, "payed" => false},
              "Nov/19" => {"amount" => 1000, "payed" => false},
              "total_investment" => 10000, "debt" => 3000
            }
          }
        ]

        expect(json['investors']).to eq(data)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      after do
        Timecop.return
      end
    end

    context 'when in the end of period' do
      before do
        t = "2019-03-10T06:23:51.04+03:00".to_datetime
        Timecop.freeze(t)

        invested_company.date_from = "2019-03-11"
        invested_company.date_to = "2019-12-11"
        invested_company.save!

        invested_company2.date_from = "2019-03-11"
        invested_company2.date_to = "2019-12-11"
        invested_company2.save!

        t = "2019-11-10T06:23:51.04+03:00".to_datetime
        Timecop.freeze(t)

        post "/auth/login", params: {email: user.email, password: password}
        token = json['token']

        get "/tracking/startup", headers: {'Authorization': token}
      end

      it "returns axis and data" do
        expect(json['axis']).to be_present
        expect(json['investors']).to be_present
      end

      it "returns axis from registration date to now" do
        axis_dates = ["Sep/19", "Oct/19", "Nov/19", "Dec/19", "Jan/20"]

        expect(json['axis']).to eq(axis_dates)
      end

      it "returns year investment data" do
        data = [
          {
            "#{investor.name} #{investor.surname}" => {
              "Sep/19" => {"amount" => 1000, "payed" => false},
              "Oct/19" => {"amount" => 1000, "payed" => false},
              "Nov/19" => {"amount" => 1000, "payed" => false},
              "Dec/19" => {"amount" => 1000, "payed" => false},
              "Jan/20" => {"amount" => 0, "payed" => false},
              "total_investment" => 10000, "debt" => 10000
            }
          },
          {
            "#{investor2.name} #{investor2.surname}" => {
              "Sep/19" => {"amount" => 1000, "payed" => false},
              "Oct/19" => {"amount" => 1000, "payed" => false},
              "Nov/19" => {"amount" => 1000, "payed" => false},
              "Dec/19" => {"amount" => 1000, "payed" => false},
              "Jan/20" => {"amount" => 0, "payed" => false},
              "total_investment" => 10000, "debt" => 10000
            }
          }
        ]

        expect(json['investors']).to eq(data)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      after do
        Timecop.return
      end
    end

    context 'when  double invested' do
      before do
        t = "2019-02-10T06:23:51.04+03:00".to_datetime
        Timecop.freeze(t)

        invested_company.date_from = "2019-02-11"
        invested_company.date_to = "2019-11-11"
        invested_company.save!

        t = "2019-03-10T06:23:51.04+03:00".to_datetime
        Timecop.freeze(t)

        invested_company2.date_from = "2019-03-11"
        invested_company2.date_to = "2019-12-11"
        invested_company2.save!

        InvestedCompany.create!(
          company_id: company.id,
          investor_id: investor.id,
          contact_email: company.contact_email,
          investment: 1000,
          evaluation: 10,
          date_from: "2019-03-13",
          date_to: "2019-12-13"
        )

        InvestmentPayed.create!(
          invested_company: invested_company,
          date: "2019-03-13",
          amount: 1000
        )

        post "/auth/login", params: {email: user.email, password: password}
        token = json['token']

        get "/tracking/startup", headers: {'Authorization': token}
      end

      it "returns axis and data" do
        expect(json['axis']).to be_present
        expect(json['investors']).to be_present
      end

      it "returns axis from registration date to now" do
        axis_dates = ["Jan/19", "Feb/19", "Mar/19", "Apr/19", "May/19"]

        expect(json['axis']).to eq(axis_dates)
      end

      it "returns year investment data" do
        data = [
          {
            "#{investor.name} #{investor.surname}" => {
              "Jan/19" => {"amount" => 0, "payed" => false},
              "Feb/19" => {"amount" => 1000, "payed" => false},
              "Mar/19" => {"amount" => 1000, "payed" => true},
              "Apr/19" => {"amount" => 1000, "payed" => false},
              "May/19" => {"amount" => 1000, "payed" => false},
              "total_investment" => 10000, "debt" => 9000
            }
          },
          {
            "#{investor2.name} #{investor2.surname}" => {
              "Jan/19" => {"amount" => 0, "payed" => false},
              "Feb/19" => {"amount" => 0, "payed" => false},
              "Mar/19" => {"amount" => 1000, "payed" => false},
              "Apr/19" => {"amount" => 1000, "payed" => false},
              "May/19" => {"amount" => 1000, "payed" => false},
              "total_investment" => 10000, "debt" => 10000
            }
          },
          {
            "#{investor.name} #{investor.surname}" => {
              "Jan/19" => {"amount" => 0, "payed" => false},
              "Feb/19" => {"amount" => 0, "payed" => false},
              "Mar/19" => {"amount" => 100, "payed" => false},
              "Apr/19" => {"amount" => 100, "payed" => false},
              "May/19" => {"amount" => 100, "payed" => false},
              "total_investment" => 1000, "debt" => 1000
            }
          },
        ]

        expect(json['investors']).to eq(data)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      after do
        Timecop.return
      end
    end
  end

  # Test suite for GET /tracking/investor
  describe 'GET /tracking/investor' do
    context 'when simply get' do
      before do
        t = "2019-02-10T06:23:51.04+03:00".to_datetime
        Timecop.freeze(t)

        invested_company.date_from = "2019-02-11"
        invested_company.date_to = "2019-11-11"
        invested_company.save!

        t = "2019-03-10T06:23:51.04+03:00".to_datetime
        Timecop.freeze(t)

        invested_company3.date_from = "2019-03-11"
        invested_company3.date_to = "2019-12-11"
        invested_company3.save!

        InvestmentPayed.create!(
          invested_company: invested_company3,
          date: "2019-03-13",
          amount: 1000
        )

        post "/auth/login", params: {email: investor.email, password: password}
        token = json['token']

        get "/tracking/investor", headers: {'Authorization': token}
      end

      it "returns axis and data" do
        expect(json['axis']).to be_present
        expect(json['companies']).to be_present
      end

      it "returns axis from registration date to now" do
        axis_dates = ["Jan/19", "Feb/19", "Mar/19", "Apr/19", "May/19"]

        expect(json['axis']).to eq(axis_dates)
      end

      it "returns year investment data" do
        data = [
          {
            "#{company.company_name}" => {
              "Jan/19" => {"amount" => 0, "payed" => false},
              "Feb/19" => {"amount" => 1000, "payed" => false},
              "Mar/19" => {"amount" => 1000, "payed" => false},
              "Apr/19" => {"amount" => 1000, "payed" => false},
              "May/19" => {"amount" => 1000, "payed" => false},
              "total_investment" => 10000, "debt" => 10000,
              "company_id" => invested_company.id
            }
          },
          {
            "#{company2.company_name}" => {
              "Jan/19" => {"amount" => 0, "payed" => false},
              "Feb/19" => {"amount" => 0, "payed" => false},
              "Mar/19" => {"amount" => 1000, "payed" => true},
              "Apr/19" => {"amount" => 1000, "payed" => false},
              "May/19" => {"amount" => 1000, "payed" => false},
              "total_investment" => 10000, "debt" => 9000,
              "company_id" => invested_company3.id
            }
          }
        ]

        expect(json['companies']).to eq(data)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      after do
        Timecop.return
      end
    end

    context 'when in the middle of period' do
      before do
        t = "2019-02-10T06:23:51.04+03:00".to_datetime
        Timecop.freeze(t)

        invested_company.date_from = "2019-02-11"
        invested_company.date_to = "2019-11-11"
        invested_company.save!

        t = "2019-03-10T06:23:51.04+03:00".to_datetime
        Timecop.freeze(t)

        invested_company3.date_from = "2019-03-11"
        invested_company3.date_to = "2019-12-11"
        invested_company3.save!

        ["2019-03-11", "2019-04-11", "2019-05-11", "2019-06-11", "2019-07-11", "2019-08-11", "2019-09-11"].each do |date|
          t = date.to_datetime
          Timecop.freeze(t)

          InvestmentPayed.create!(
            invested_company: invested_company3,
            date: date,
            amount: 1000
          )
        end

        t = "2019-09-10T06:23:51.04+03:00".to_datetime
        Timecop.freeze(t)

        post "/auth/login", params: {email: investor.email, password: password}
        token = json['token']

        get "/tracking/investor", headers: {'Authorization': token}
      end

      it "returns axis and data" do
        expect(json['axis']).to be_present
        expect(json['companies']).to be_present
      end

      it "returns axis from registration date to now" do
        axis_dates = ["Jul/19", "Aug/19", "Sep/19", "Oct/19", "Nov/19"]

        expect(json['axis']).to eq(axis_dates)
      end

      it "returns year investment data" do
        data = [
          {
            "#{company.company_name}" => {
              "Jul/19" => {"amount" => 1000, "payed" => false},
              "Aug/19" => {"amount" => 1000, "payed" => false},
              "Sep/19" => {"amount" => 1000, "payed" => false},
              "Oct/19" => {"amount" => 1000, "payed" => false},
              "Nov/19" => {"amount" => 1000, "payed" => false},
              "total_investment" => 10000, "debt" => 10000,
              "company_id" => invested_company.id
            }
          },
          {
            "#{company2.company_name}" => {
              "Jul/19" => {"amount" => 1000, "payed" => true},
              "Aug/19" => {"amount" => 1000, "payed" => true},
              "Sep/19" => {"amount" => 1000, "payed" => true},
              "Oct/19" => {"amount" => 1000, "payed" => false},
              "Nov/19" => {"amount" => 1000, "payed" => false},
              "total_investment" => 10000, "debt" => 3000,
              "company_id" => invested_company3.id
            }
          }
        ]

        expect(json['companies']).to eq(data)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      after do
        Timecop.return
      end
    end

    context 'when in the middle of period' do
      before do
        t = "2019-03-10T06:23:51.04+03:00".to_datetime
        Timecop.freeze(t)

        invested_company.date_from = "2019-03-11"
        invested_company.date_to = "2019-12-11"
        invested_company.save!

        invested_company3.date_from = "2019-03-11"
        invested_company3.date_to = "2019-12-11"
        invested_company3.save!

        t = "2019-11-10T06:23:51.04+03:00".to_datetime
        Timecop.freeze(t)

        post "/auth/login", params: {email: investor.email, password: password}
        token = json['token']

        get "/tracking/investor", headers: {'Authorization': token}
      end

      it "returns axis and data" do
        expect(json['axis']).to be_present
        expect(json['companies']).to be_present
      end

      it "returns axis from registration date to now" do
        axis_dates = ["Sep/19", "Oct/19", "Nov/19", "Dec/19", "Jan/20"]

        expect(json['axis']).to eq(axis_dates)
      end

      it "returns year investment data" do
        data = [
          {
            "#{company.company_name}" => {
              "Sep/19" => {"amount" => 1000, "payed" => false},
              "Oct/19" => {"amount" => 1000, "payed" => false},
              "Nov/19" => {"amount" => 1000, "payed" => false},
              "Dec/19" => {"amount" => 1000, "payed" => false},
              "Jan/20" => {"amount" => 0, "payed" => false},
              "total_investment" => 10000, "debt" => 10000,
              "company_id" => invested_company.id
            }
          },
          {
            "#{company2.company_name}" => {
              "Sep/19" => {"amount" => 1000, "payed" => false},
              "Oct/19" => {"amount" => 1000, "payed" => false},
              "Nov/19" => {"amount" => 1000, "payed" => false},
              "Dec/19" => {"amount" => 1000, "payed" => false},
              "Jan/20" => {"amount" => 0, "payed" => false},
              "total_investment" => 10000, "debt" => 10000,
              "company_id" => invested_company3.id
            }
          }
        ]

        expect(json['companies']).to eq(data)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      after do
        Timecop.return
      end
    end

    context 'when  double invested' do
      before do
        t = "2019-02-10T06:23:51.04+03:00".to_datetime
        Timecop.freeze(t)

        invested_company.date_from = "2019-02-11"
        invested_company.date_to = "2019-11-11"
        invested_company.save!

        t = "2019-03-10T06:23:51.04+03:00".to_datetime
        Timecop.freeze(t)

        invested_company3.date_from = "2019-03-11"
        invested_company3.date_to = "2019-12-11"
        invested_company3.save!

        InvestedCompany.create!(
          company_id: company.id,
          investor_id: investor.id,
          contact_email: company.contact_email,
          investment: 1000,
          evaluation: 10,
          date_from: "2019-03-13",
          date_to: "2019-12-13"
        )

        InvestmentPayed.create!(
          invested_company: invested_company,
          date: "2019-03-13",
          amount: 1000
        )

        post "/auth/login", params: {email: investor.email, password: password}
        token = json['token']

        get "/tracking/investor", headers: {'Authorization': token}
      end

      it "returns axis and data" do
        expect(json['axis']).to be_present
        expect(json['companies']).to be_present
      end

      it "returns axis from registration date to now" do
        axis_dates = ["Jan/19", "Feb/19", "Mar/19", "Apr/19", "May/19"]

        expect(json['axis']).to eq(axis_dates)
      end

      it "returns year investment data" do
        data = [
          {
            "#{company.company_name}" => {
              "Jan/19" => {"amount" => 0, "payed" => false},
              "Feb/19" => {"amount" => 1000, "payed" => false},
              "Mar/19" => {"amount" => 1000, "payed" => true},
              "Apr/19" => {"amount" => 1000, "payed" => false},
              "May/19" => {"amount" => 1000, "payed" => false},
              "total_investment" => 10000, "debt" => 9000,
              "company_id" => invested_company.id
            }
          },
          {
            "#{company2.company_name}" => {
              "Jan/19" => {"amount" => 0, "payed" => false},
              "Feb/19" => {"amount" => 0, "payed" => false},
              "Mar/19" => {"amount" => 1000, "payed" => false},
              "Apr/19" => {"amount" => 1000, "payed" => false},
              "May/19" => {"amount" => 1000, "payed" => false},
              "total_investment" => 10000, "debt" => 10000,
              "company_id" => invested_company3.id
            }
          },
          {
            "#{company.company_name}" => {
              "Jan/19" => {"amount" => 0, "payed" => false},
              "Feb/19" => {"amount" => 0, "payed" => false},
              "Mar/19" => {"amount" => 100, "payed" => false},
              "Apr/19" => {"amount" => 100, "payed" => false},
              "May/19" => {"amount" => 100, "payed" => false},
              "total_investment" => 1000, "debt" => 1000,
              "company_id" => InvestedCompany.last.id
            }
          },
        ]

        expect(json['companies']).to eq(data)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      after do
        Timecop.return
      end
    end
  end

  # Test suite for POST /tracking/mark_payed
  describe 'POST /tracking/mark_payed' do
    context 'when valid attributes' do
      before do
        post "/auth/login", params: {email: investor.email, password: password}
        token = json['token']

        post "/tracking/mark_payed", params: {company_id: invested_company.id, date: DateTime.now}, headers: {'Authorization': token}
      end

      it 'response is empty' do
        expect(response.body).to match("")
      end

      it 'returns status code 201' do
        expect(response).to have_http_status(201)
      end
    end

    context 'when dublicates' do
      before do
        post "/auth/login", params: {email: investor.email, password: password}
        token = json['token']

        InvestmentPayed.create!(
          invested_company: invested_company,
          date: DateTime.now,
          amount: invested_company.investment / 10
        )

        post "/tracking/mark_payed", params: {company_id: invested_company.id, date: DateTime.now}, headers: {'Authorization': token}
      end

      it 'response with error' do
        expect(response.body)
          .to match("{\"errors\":\"ALREADY_PAYED\"}")
      end

      it 'returns status code 403' do
        expect(response).to have_http_status(403)
      end
    end

    context 'when date out of period' do
      before do
        post "/auth/login", params: {email: investor.email, password: password}
        token = json['token']

        post "/tracking/mark_payed", params: {company_id: invested_company.id, date: DateTime.now.last_month}, headers: {'Authorization': token}
      end

      it 'response with error' do
        expect(response.body)
          .to match("{\"errors\":\"INVALID_DATE\"}")
      end

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end
    end

    context 'when date in the future month' do
      before do
        post "/auth/login", params: {email: investor.email, password: password}
        token = json['token']

        post "/tracking/mark_payed", params: {company_id: invested_company.id, date: DateTime.now.next_month}, headers: {'Authorization': token}
      end

      it 'returns a validation failure message' do
        expect(response.body)
          .to match("{\"date\":[\"can't be in the future\"]}")
      end

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end
    end

    context 'when date in the future but current month' do
      before do
        post "/auth/login", params: {email: investor.email, password: password}
        token = json['token']

        post "/tracking/mark_payed", params: {company_id: invested_company.id, date: DateTime.now.end_of_month}, headers: {'Authorization': token}
      end

      it 'response is empty' do
        expect(response.body).to match("")
      end

      it 'returns status code 201' do
        expect(response).to have_http_status(201)
      end
    end

    context 'when company does not exitst' do
      before do
        post "/auth/login", params: {email: investor.email, password: password}
        token = json['token']

        post "/tracking/mark_payed", params: {company_id: 0, date: DateTime.now.end_of_month}, headers: {'Authorization': token}
      end

      it 'response is empty' do
        expect(response.body).to match("")
      end

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end
    end

    context 'when without date' do
      before do
        post "/auth/login", params: {email: investor.email, password: password}
        token = json['token']

        post "/tracking/mark_payed", params: {company_id: invested_company.id}, headers: {'Authorization': token}
      end

      it 'returns a validation failure message' do
        expect(response.body)
          .to match("{\"date\":[\"can't be blank\"]}")
      end

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end
    end

    context 'when not authorized' do
      before do
        post "/tracking/mark_payed", params: {company_id: 0, date: DateTime.now.end_of_month}
      end

      it 'response is empty' do
        expect(response.body).to match("")
      end

      it 'returns status code 401' do
        expect(response).to have_http_status(401)
      end
    end
  end
end


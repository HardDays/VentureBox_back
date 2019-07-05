require 'rails_helper'

RSpec.describe "TrackingSpec", type: :request do
  let(:password) { "123123" }
  let!(:user)  { create(:user, password: password, password_confirmation: password, role: :startup) }
  let!(:company) { create(:company, user_id: user.id, created_at: "2019-02-01T18:23:51.04+03:00".to_datetime) }
  let!(:company_item) { create(:company_item, company_id: company.id) }

  let!(:user2)  { create(:user, password: password, password_confirmation: password, role: :startup) }
  let!(:company2) { create(:company, user_id: user2.id) }

  let!(:user3)  { create(:user, password: password, password_confirmation: password, role: :startup) }
  let!(:company3) { create(:company, user_id: user3.id) }

  let!(:investor) { create(:user, password: password, password_confirmation: password, role: :investor )}
  let!(:invested_company) { create(:invested_company, investment: 10000, evaluation: 10, company_id: company.id,
                                   investor_id: investor.id)}
  let!(:invested_company3) { create(:invested_company, investment: 10000, evaluation: 10, company_id: company2.id,
                                    investor_id: investor.id)}

  let!(:investor2) { create(:user, password: password, password_confirmation: password, role: :investor )}
  let!(:invested_company2) { create(:invested_company, investment: 10000, evaluation: 10, company_id: company.id,
                                   investor_id: investor2.id)}


  # Test suite for GET /tracking/startup
  describe 'GET /tracking/startup' do
    context 'when simply get' do
      before do
        t = "2019-03-10T06:23:51.04+03:00".to_datetime
        Timecop.freeze(t)

        invested_company.date_from = "2019-03-11"
        invested_company.date_to = "2020-01-11"
        invested_company.save!

        invested_company2.date_from = "2019-03-11"
        invested_company2.date_to = "2020-01-11"
        invested_company2.save!

        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        get "/tracking/startup", headers: { 'Authorization': token }
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
        data = {
          "#{investor.name} #{investor.surname}" => {
            "Jan/19" => 0, "Feb/19" => 0, "Mar/19" => 1000, "Apr/19" => 1000, "May/19" => 1000
          },
          "#{investor2.name} #{investor2.surname}" => {
            "Jan/19" => 0, "Feb/19" => 0, "Mar/19" => 1000, "Apr/19" => 1000, "May/19" => 1000
          }
        }

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
        t = "2019-03-10T06:23:51.04+03:00".to_datetime
        Timecop.freeze(t)

        invested_company.date_from = "2019-03-11"
        invested_company.date_to = "2020-01-11"
        invested_company.save!

        invested_company2.date_from = "2019-03-11"
        invested_company2.date_to = "2020-01-11"
        invested_company2.save!

        t = "2019-09-10T06:23:51.04+03:00".to_datetime
        Timecop.freeze(t)

        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        get "/tracking/startup", headers: { 'Authorization': token }
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
        data = {
          "#{investor.name} #{investor.surname}" => {
            "Jul/19" => 1000, "Aug/19" => 1000, "Sep/19" => 1000, "Oct/19" => 1000, "Nov/19" => 1000
          },
          "#{investor2.name} #{investor2.surname}" => {
            "Jul/19" => 1000, "Aug/19" => 1000, "Sep/19" => 1000, "Oct/19" => 1000, "Nov/19" => 1000
          }
        }

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
        t = "2019-03-10T06:23:51.04+03:00".to_datetime
        Timecop.freeze(t)

        invested_company.date_from = "2019-03-11"
        invested_company.date_to = "2020-01-11"
        invested_company.save!

        invested_company2.date_from = "2019-03-11"
        invested_company2.date_to = "2020-01-11"
        invested_company2.save!

        InvestedCompany.create!(
          company_id: company.id,
          investor_id: investor.id,
          contact_email: company.contact_email,
          investment: 1000,
          evaluation: 10,
          date_from: "2019-03-13",
          date_to: "2020-01-13"
        )

        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        get "/tracking/startup", headers: { 'Authorization': token }
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
        data = {
          "#{investor.name} #{investor.surname}" => {
            "Jan/19"=>0, "Feb/19"=>0, "Mar/19"=>1100, "Apr/19"=>1100, "May/19"=>1100
          },
          "#{investor2.name} #{investor2.surname}" => {
            "Jan/19"=>0, "Feb/19"=>0, "Mar/19"=>1000, "Apr/19"=>1000, "May/19"=>1000
          }
        }

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
        t = "2019-03-10T06:23:51.04+03:00".to_datetime
        Timecop.freeze(t)

        invested_company.date_from = "2019-03-11"
        invested_company.date_to = "2020-01-11"
        invested_company.save!

        invested_company3.date_from = "2019-03-11"
        invested_company3.date_to = "2020-01-11"
        invested_company3.save!

        post "/auth/login", params: { email: investor.email, password: password}
        token = json['token']

        get "/tracking/investor", headers: { 'Authorization': token }
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
        data = {
          "#{company.company_name}" => {
            "Jan/19" => 0, "Feb/19" => 0, "Mar/19" => 1000, "Apr/19" => 1000, "May/19" => 1000
          },
          "#{company2.company_name}" => {
            "Jan/19" => 0, "Feb/19" => 0, "Mar/19" => 1000, "Apr/19" => 1000, "May/19" => 1000
          }
        }

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
        invested_company.date_to = "2020-01-11"
        invested_company.save!

        invested_company3.date_from = "2019-03-11"
        invested_company3.date_to = "2020-01-11"
        invested_company3.save!

        t = "2019-09-10T06:23:51.04+03:00".to_datetime
        Timecop.freeze(t)

        post "/auth/login", params: { email: investor.email, password: password}
        token = json['token']

        get "/tracking/investor", headers: { 'Authorization': token }
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
        data = {
          "#{company.company_name}" => {
            "Jul/19" => 1000, "Aug/19" => 1000, "Sep/19" => 1000, "Oct/19" => 1000, "Nov/19" => 1000
          },
          "#{company2.company_name}" => {
            "Jul/19" => 1000, "Aug/19" => 1000, "Sep/19" => 1000, "Oct/19" => 1000, "Nov/19" => 1000
          }
        }

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
        t = "2019-03-10T06:23:51.04+03:00".to_datetime
        Timecop.freeze(t)

        invested_company.date_from = "2019-03-11"
        invested_company.date_to = "2020-01-11"
        invested_company.save!

        invested_company3.date_from = "2019-03-11"
        invested_company3.date_to = "2020-01-11"
        invested_company3.save!

        InvestedCompany.create!(
          company_id: company.id,
          investor_id: investor.id,
          contact_email: company.contact_email,
          investment: 1000,
          evaluation: 10,
          date_from: "2019-03-13",
          date_to: "2020-01-13"
        )

        post "/auth/login", params: { email: investor.email, password: password}
        token = json['token']

        get "/tracking/investor", headers: { 'Authorization': token }
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
        data = {
          "#{company.company_name}" => {
            "Jan/19"=>0, "Feb/19"=>0, "Mar/19"=>1100, "Apr/19"=>1100, "May/19"=>1100
          },
          "#{company2.company_name}" => {
            "Jan/19"=>0, "Feb/19"=>0, "Mar/19"=>1000, "Apr/19"=>1000, "May/19"=>1000
          }
        }

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
end


require 'rails_helper'

RSpec.describe "InterestingCompanies", type: :request do
  let(:password) { "123123" }
  let!(:user)  { create(:user, password: password, password_confirmation: password, role: :startup) }
  let!(:company) { create(:company, user_id: user.id) }

  let!(:user2)  { create(:user, password: password, password_confirmation: password, role: :startup) }
  let!(:company2) { create(:company, user_id: user2.id) }

  let!(:user3)  { create(:user, password: password, password_confirmation: password, role: :startup) }
  let!(:company3) { create(:company, user_id: user3.id) }

  let!(:user4)  { create(:user, password: password, password_confirmation: password, role: :startup) }
  let!(:company4) { create(:company, user_id: user4.id) }

  let!(:investor) { create(:user, password: password, password_confirmation: password, role: :investor )}
  let!(:interesting_company1) { create(:interesting_company, company_id: company.id, investor_id: investor.id)}
  let!(:interesting_company2) { create(:interesting_company, company_id: company2.id, investor_id: investor.id)}
  let!(:interesting_company3) { create(:interesting_company, company_id: company3.id, investor_id: investor.id)}
  let!(:invested_company) { create(:invested_company, company_id: company4.id, investor_id: investor.id)}

  let!(:investor2) { create(:user, password: password, password_confirmation: password, role: :investor )}
  let!(:interesting_company4) { create(:interesting_company, company_id: company.id, investor_id: investor2.id)}
  let!(:interesting_company5) { create(:interesting_company, company_id: company2.id, investor_id: investor2.id)}

  # Test suite for GET /interesting_companies
  describe 'GET /interesting_companies' do
    context 'when simply get' do
      before do
        post "/auth/login", params: { email: investor.email, password: password}
        token = json['token']

        get "/interesting_companies", headers: { 'Authorization': token }
      end

      it "return all companies" do
        expect(json).not_to be_empty
        expect(json['count']).to eq(3)
        expect(json['items'].size).to eq(3)
      end

      it "return all company info" do
        expect(json['items'][0]["company_id"]).to be_a_kind_of(Integer)
        expect(json['items'][0]["company_name"]).to be_a_kind_of(String)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when use limit' do
      before do
        post "/auth/login", params: { email: investor.email, password: password}
        token = json['token']

        get "/interesting_companies", params: {limit: 2}, headers: { 'Authorization': token }
      end

      it "returns 2 entities" do
        expect(json).not_to be_empty
        expect(json['count']).to eq(3)
        expect(json['items'].size).to eq(2)
      end

      it "return all company info" do
        expect(json['items'][0]["company_id"]).to be_a_kind_of(Integer)
        expect(json['items'][0]["company_name"]).to be_a_kind_of(String)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when use offset' do
      before do
        post "/auth/login", params: { email: investor.email, password: password}
        token = json['token']

        get "/interesting_companies", params: {offset: 2}, headers: { 'Authorization': token }
      end

      it "returns response with offset" do
        expect(json).not_to be_empty
        expect(json['count']).to eq(3)
        expect(json['items'].size).to eq(1)
      end

      it "return all company info" do
        expect(json['items'][0]["company_id"]).to be_a_kind_of(Integer)
        expect(json['items'][0]["company_name"]).to be_a_kind_of(String)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when i am startup' do
      before do
        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        get "/interesting_companies", headers: { 'Authorization': token }
      end

      it 'returns status code 401' do
        expect(response).to have_http_status(401)
      end

      it 'response is empty' do
        expect(response.body).to match("")
      end
    end

    context 'when not authorized' do
      before do
        get "/interesting_companies"
      end

      it 'returns status code 401' do
        expect(response).to have_http_status(401)
      end

      it 'response is empty' do
        expect(response.body).to match("")
      end
    end
  end

  # Test suite for POST /companies/1/interesting_companies
  describe 'POST /companies/1/interesting_companies' do
    context 'when the request is valid' do
      before do
        post "/auth/login", params: { email: investor2.email, password: password}
        token = json['token']

        post "/companies/#{company3.id}/interesting_companies", headers: { 'Authorization': token }
      end

      it 'creates a company' do
        expect(json['company_name']).to eq(company3.name)
        expect(json['company_id']).to eq(company3.id)
      end

      it 'returns status code 201' do
        expect(response).to have_http_status(201)
      end
    end

    context 'when i am already invested' do
      before do
        post "/auth/login", params: { email: investor.email, password: password}
        token = json['token']

        post "/companies/#{company4.id}/interesting_companies", headers: { 'Authorization': token }
      end

      it 'returns status code 403' do
        expect(response).to have_http_status(403)
      end

      it 'response is empty' do
        expect(response.body)
          .to match("{\"errors\":\"ALREADY_INVESTED\"}")
      end
    end

    context 'when i am startup' do
      before do
        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        post "/companies/#{company.id}/interesting_companies", headers: { 'Authorization': token }
      end

      it 'returns status code 401' do
        expect(response).to have_http_status(401)
      end

      it 'response is empty' do
        expect(response.body).to match("")
      end
    end

    context 'when the user unauthorized' do
      before do
        post "/companies/#{company4.id}/interesting_companies"
      end

      it 'returns status code 401' do
        expect(response).to have_http_status(401)
      end

      it 'response is empty' do
        expect(response.body).to match("")
      end
    end
  end

  # Test suite for DELETE /interesting_companies/1
  describe 'DELETE /interesting_companies/1' do
    context 'when the request is valid' do
      before do
        post "/auth/login", params: { email: investor.email, password: password}
        token = json['token']

        delete "/interesting_companies/#{interesting_company1.id}", headers: { 'Authorization': token }
      end

      it 'response is empty' do
        expect(response.body).to match("")
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when not exist' do
      before do
        post "/auth/login", params: { email: investor.email, password: password}
        token = json['token']

        delete "/interesting_companies/0", headers: { 'Authorization': token }
      end

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'response is empty' do
        expect(response.body).to match("")
      end
    end

    context 'when not my item' do
      before do
        post "/auth/login", params: { email: investor.email, password: password}
        token = json['token']

        delete "/interesting_companies/#{interesting_company4.id}", headers: { 'Authorization': token }
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
        delete "/interesting_companies/#{interesting_company1.id}"
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

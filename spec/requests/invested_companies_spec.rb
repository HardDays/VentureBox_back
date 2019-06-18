require 'rails_helper'

RSpec.describe "InvestedCompanies", type: :request do
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
  let!(:invested_company1) { create(:invested_company, company_id: company.id, investor_id: investor.id)}
  let!(:invested_company2) { create(:invested_company, company_id: company2.id, investor_id: investor.id)}
  let!(:invested_company3) { create(:invested_company, company_id: company3.id, investor_id: investor.id)}

  let!(:investor2) { create(:user, password: password, password_confirmation: password, role: :investor )}
  let!(:invested_company4) { create(:invested_company, company_id: company.id, investor_id: investor2.id)}
  let!(:invested_company5) { create(:invested_company, company_id: company2.id, investor_id: investor2.id)}

  let(:valid_attributes) { { investment: 1000000, evaluation: 10, contact_email: company4.contact_email } }
  let(:without_investment) { { evaluation: 10, contact_email: company4.contact_email } }
  let(:without_evaluation) { { investment: 1000000, contact_email: company4.contact_email } }
  let(:without_contact_email) { { investment: 1000000, evaluation: 10 } }
  let(:context_email_not_match) { { investment: 1000000, evaluation: 10, contact_email: company.contact_email } }
  let(:wrong_contact_email_format) { { investment: 1000000, evaluation: 10 , contact_email: "contactemail.com" } }

  # Test suite for GET /invested_companies
  describe 'GET /invested_companies' do
    context 'when simply get' do
      before do
        post "/auth/login", params: { email: investor.email, password: password}
        token = json['token']

        get "/invested_companies", headers: { 'Authorization': token }
      end

      it "return all companies" do
        expect(json).not_to be_empty
        expect(json['count']).to eq(3)
        expect(json['items'].size).to eq(3)
      end

      it "return all company info" do
        expect(json['items'][0]["company_id"]).to be_a_kind_of(Integer)
        expect(json['items'][0]["company_name"]).to be_a_kind_of(String)
        expect(json['items'][0]["company_has_image"]).to be_in([true, false])
        expect(json['items'][0]["investment"]).to be_a_kind_of(Integer)
        expect(json['items'][0]["evaluation"]).to be_a_kind_of(Integer)
        expect(json['items'][0]["contact_email"]).not_to be_present
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when use limit' do
      before do
        post "/auth/login", params: { email: investor.email, password: password}
        token = json['token']

        get "/invested_companies", params: {limit: 2}, headers: { 'Authorization': token }
      end

      it "returns 2 entities" do
        expect(json).not_to be_empty
        expect(json['count']).to eq(3)
        expect(json['items'].size).to eq(2)
      end

      it "return all company info" do
        expect(json['items'][0]["company_id"]).to be_a_kind_of(Integer)
        expect(json['items'][0]["company_name"]).to be_a_kind_of(String)
        expect(json['items'][0]["company_has_image"]).to be_in([true, false])
        expect(json['items'][0]["investment"]).to be_a_kind_of(Integer)
        expect(json['items'][0]["evaluation"]).to be_a_kind_of(Integer)
        expect(json['items'][0]["contact_email"]).not_to be_present
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when use offset' do
      before do
        post "/auth/login", params: { email: investor.email, password: password}
        token = json['token']

        get "/invested_companies", params: {offset: 2}, headers: { 'Authorization': token }
      end

      it "returns response with offset" do
        expect(json).not_to be_empty
        expect(json['count']).to eq(3)
        expect(json['items'].size).to eq(1)
      end

      it "return all company info" do
        expect(json['items'][0]["company_id"]).to be_a_kind_of(Integer)
        expect(json['items'][0]["company_name"]).to be_a_kind_of(String)
        expect(json['items'][0]["company_has_image"]).to be_in([true, false])
        expect(json['items'][0]["investment"]).to be_a_kind_of(Integer)
        expect(json['items'][0]["evaluation"]).to be_a_kind_of(Integer)
        expect(json['items'][0]["contact_email"]).not_to be_present
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when i invested more that once' do
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

        get "/invested_companies", headers: { 'Authorization': token }
      end

      it "returns response count not change" do
        expect(json).not_to be_empty
        expect(json['count']).to eq(3)
        expect(json['items'].size).to eq(3)
      end

      it "return all company info" do
        expect(json['items'][0]["company_id"]).to be_a_kind_of(Integer)
        expect(json['items'][0]["company_name"]).to be_a_kind_of(String)
        expect(json['items'][0]["company_has_image"]).to be_in([true, false])
        expect(json['items'][0]["investment"]).to be_a_kind_of(Integer)
        expect(json['items'][0]["evaluation"]).to be_a_kind_of(Integer)
        expect(json['items'][0]["contact_email"]).not_to be_present
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when i am startup' do
      before do
        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        get "/invested_companies", headers: { 'Authorization': token }
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
        get "/invested_companies"
      end

      it 'returns status code 401' do
        expect(response).to have_http_status(401)
      end

      it 'response is empty' do
        expect(response.body).to match("")
      end
    end
  end

  # Test suite for GET users/1/companies/1/investors
  describe 'GET /users/1/investors' do
    context 'when simply get' do
      before do
        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        get "/users/#{user.id}/companies/#{company.id}/investors", headers: { 'Authorization': token }
      end

      it "return all investors" do
        expect(json).not_to be_empty
        expect(json['count']).to eq(2)
        expect(json['items'].size).to eq(2)
      end

      it "return all company info" do
        expect(json['items'][0]["id"]).to be_a_kind_of(Integer)
        expect(json['items'][0]["investor_id"]).to be_a_kind_of(Integer)
        expect(json['items'][0]["investor_name"]).to be_a_kind_of(String)
        expect(json['items'][0]["investor_email"]).to be_a_kind_of(String)
        expect(json['items'][0]["investment"]).to be_a_kind_of(Integer)
        expect(json['items'][0]["evaluation"]).to be_a_kind_of(Integer)
        expect(json['items'][0]["contact_email"]).not_to be_present
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when use limit' do
      before do
        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        get "/users/#{user.id}/companies/#{company.id}/investors", params: {limit: 1}, headers: { 'Authorization': token }
      end

      it "returns 2 entities" do
        expect(json).not_to be_empty
        expect(json['count']).to eq(2)
        expect(json['items'].size).to eq(1)
      end

      it "return all company info" do
        expect(json['items'][0]["id"]).to be_a_kind_of(Integer)
        expect(json['items'][0]["investor_id"]).to be_a_kind_of(Integer)
        expect(json['items'][0]["investor_name"]).to be_a_kind_of(String)
        expect(json['items'][0]["investor_email"]).to be_a_kind_of(String)
        expect(json['items'][0]["investment"]).to be_a_kind_of(Integer)
        expect(json['items'][0]["evaluation"]).to be_a_kind_of(Integer)
        expect(json['items'][0]["contact_email"]).not_to be_present
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when use offset' do
      before do
        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        get "/users/#{user.id}/companies/#{company.id}/investors", params: {offset: 1}, headers: { 'Authorization': token }
      end

      it "returns response with offset" do
        expect(json).not_to be_empty
        expect(json['count']).to eq(2)
        expect(json['items'].size).to eq(1)
      end

      it "return all company info" do
        expect(json['items'][0]["id"]).to be_a_kind_of(Integer)
        expect(json['items'][0]["investor_id"]).to be_a_kind_of(Integer)
        expect(json['items'][0]["investor_name"]).to be_a_kind_of(String)
        expect(json['items'][0]["investor_email"]).to be_a_kind_of(String)
        expect(json['items'][0]["investment"]).to be_a_kind_of(Integer)
        expect(json['items'][0]["evaluation"]).to be_a_kind_of(Integer)
        expect(json['items'][0]["contact_email"]).not_to be_present
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when invested more that once' do
      before do
        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        investment = InvestedCompany.new(
          investor_id: investor.id,
          company_id: company.id,
          investment: 100,
          evaluation: 1,
          contact_email: company.contact_email)
        investment.save!

        get "/users/#{user.id}/companies/#{company.id}/investors", params: {offset: 1}, headers: { 'Authorization': token }
      end

      it "returns response with offset" do
        expect(json).not_to be_empty
        expect(json['count']).to eq(2)
        expect(json['items'].size).to eq(1)
      end

      it "return all company info" do
        expect(json['items'][0]["id"]).to be_a_kind_of(Integer)
        expect(json['items'][0]["investor_id"]).to be_a_kind_of(Integer)
        expect(json['items'][0]["investor_name"]).to be_a_kind_of(String)
        expect(json['items'][0]["investor_email"]).to be_a_kind_of(String)
        expect(json['items'][0]["investment"]).to be_a_kind_of(Integer)
        expect(json['items'][0]["evaluation"]).to be_a_kind_of(Integer)
        expect(json['items'][0]["contact_email"]).not_to be_present
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when not my user' do
      before do
        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        get "/users/#{user2.id}/companies/#{company.id}/investors", headers: { 'Authorization': token }
      end

      it 'returns status code 403' do
        expect(response).to have_http_status(403)
      end

      it 'response is empty' do
        expect(response.body).to match("")
      end
    end

    context 'when not my company' do
      before do
        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        get "/users/#{user.id}/companies/#{company2.id}/investors", headers: { 'Authorization': token }
      end

      it 'returns status code 403' do
        expect(response).to have_http_status(403)
      end

      it 'response is empty' do
        expect(response.body).to match("")
      end
    end

    context 'when not authorized' do
      before do
        get "/users/#{user.id}/companies/#{company.id}/investors"
      end

      it 'returns status code 401' do
        expect(response).to have_http_status(401)
      end

      it 'response is empty' do
        expect(response.body).to match("")
      end
    end
  end

  # Test suite for POST /companies/1/invested_companies
  describe 'POST /companies/1/invested_companies' do
    context 'when the request is valid' do
      before do
        post "/auth/login", params: { email: investor.email, password: password}
        token = json['token']

        interesting_company = InterestingCompany.new(company_id: company4.id, investor_id: investor.id)
        interesting_company.save

        post "/companies/#{company4.id}/invested_companies", params: valid_attributes, headers: { 'Authorization': token }
      end

      it 'creates a company' do
        expect(json['company_name']).not_to be_present
        expect(json['company_has_image']).not_to be_present
        expect(json['company_id']).to eq(company4.id)
        expect(json['investment']).to eq(1000000)
        expect(json['evaluation']).to eq(10)
        expect(json["contact_email"]).to eq(company4.contact_email)
      end

      it 'returns status code 201' do
        expect(response).to have_http_status(201)
      end

      it 'deletes interesting company item' do
        exists = InterestingCompany.where(company_id: company4.id, investor_id: investor.id).exists?

        expect(exists).to eq(false)
      end
    end

    context 'when the request without investment' do
      before do
        post "/auth/login", params: { email: investor.email, password: password}
        token = json['token']

        interesting_company = InterestingCompany.new(company_id: company4.id, investor_id: investor.id)
        interesting_company.save

        post "/companies/#{company4.id}/invested_companies", params: without_investment, headers: { 'Authorization': token }
      end

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a validation failure message' do
        expect(response.body)
          .to match("{\"investment\":[\"can't be blank\"]}")
      end

      it 'does not deletes interesting company item' do
        exists = InterestingCompany.where(company_id: company4.id, investor_id: investor.id).exists?

        expect(exists).to eq(true)
      end
    end

    context 'when the request without evaluation' do
      before do
        post "/auth/login", params: { email: investor.email, password: password}
        token = json['token']

        interesting_company = InterestingCompany.new(company_id: company4.id, investor_id: investor.id)
        interesting_company.save

        post "/companies/#{company4.id}/invested_companies", params: without_evaluation, headers: { 'Authorization': token }
      end

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a validation failure message' do
        expect(response.body)
          .to match("{\"evaluation\":[\"can't be blank\"]}")
      end

      it 'does not deletes interesting company item' do
        exists = InterestingCompany.where(company_id: company4.id, investor_id: investor.id).exists?

        expect(exists).to eq(true)
      end
    end

    context 'when the request without email' do
      before do
        post "/auth/login", params: { email: investor.email, password: password}
        token = json['token']

        interesting_company = InterestingCompany.new(company_id: company4.id, investor_id: investor.id)
        interesting_company.save

        post "/companies/#{company4.id}/invested_companies", params: without_contact_email, headers: { 'Authorization': token }
      end

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a validation failure message' do
        expect(response.body)
          .to match("{\"contact_email\":[\"can't be blank\"]}")
      end

      it 'does not deletes interesting company item' do
        exists = InterestingCompany.where(company_id: company4.id, investor_id: investor.id).exists?

        expect(exists).to eq(true)
      end
    end

    context 'when the request with wrong email' do
      before do
        post "/auth/login", params: { email: investor.email, password: password}
        token = json['token']

        interesting_company = InterestingCompany.new(company_id: company4.id, investor_id: investor.id)
        interesting_company.save

        post "/companies/#{company4.id}/invested_companies", params: context_email_not_match, headers: { 'Authorization': token }
      end

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a validation failure message' do
        expect(response.body)
          .to match("{\"contact_email\":[\"doesn't match\"]}")
      end

      it 'does not deletes interesting company item' do
        exists = InterestingCompany.where(company_id: company4.id, investor_id: investor.id).exists?

        expect(exists).to eq(true)
      end
    end

    context 'when the request with wrong email format' do
      before do
        post "/auth/login", params: { email: investor.email, password: password}
        token = json['token']

        interesting_company = InterestingCompany.new(company_id: company4.id, investor_id: investor.id)
        interesting_company.save

        post "/companies/#{company4.id}/invested_companies", params: wrong_contact_email_format, headers: { 'Authorization': token }
      end

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a validation failure message' do
        expect(response.body)
          .to match("{\"contact_email\":[\"doesn't match\"]}")
      end

      it 'does not deletes interesting company item' do
        exists = InterestingCompany.where(company_id: company4.id, investor_id: investor.id).exists?

        expect(exists).to eq(true)
      end
    end

    context 'when i am startup' do
      before do
        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        interesting_company = InterestingCompany.new(company_id: company4.id, investor_id: investor.id)
        interesting_company.save

        post "/companies/#{company4.id}/invested_companies", params: valid_attributes, headers: { 'Authorization': token }
      end

      it 'returns status code 401' do
        expect(response).to have_http_status(401)
      end

      it 'response is empty' do
        expect(response.body).to match("")
      end

      it 'does not deletes interesting company item' do
        exists = InterestingCompany.where(company_id: company4.id, investor_id: investor.id).exists?

        expect(exists).to eq(true)
      end
    end

    context 'when the user unauthorized' do
      before do
        interesting_company = InterestingCompany.new(company_id: company4.id, investor_id: investor.id)
        interesting_company.save

        post "/companies/#{company4.id}/invested_companies", params: valid_attributes
      end

      it 'returns status code 401' do
        expect(response).to have_http_status(401)
      end

      it 'response is empty' do
        expect(response.body).to match("")
      end

      it 'does not deletes interesting company item' do
        exists = InterestingCompany.where(company_id: company4.id, investor_id: investor.id).exists?

        expect(exists).to eq(true)
      end
    end
  end
end

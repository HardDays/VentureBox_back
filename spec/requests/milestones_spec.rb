require 'rails_helper'

RSpec.describe "Milestones", type: :request do
  let(:password) { "123123" }
  let!(:user)  { create(:user, password: password, password_confirmation: password, role: :startup, status: :approved) }
  let!(:company) { create(:company, user_id: user.id) }

  let!(:milestone) { create(:milestone, company_id: company.id) }
  let!(:milestone2) { create(:milestone, company_id: company.id) }
  let!(:milestone3) { create(:milestone, company_id: company.id) }


  let!(:user2)  { create(:user, password: password, password_confirmation: password, role: :startup, status: :approved) }
  let!(:company2) { create(:company, user_id: user2.id) }
  let!(:milestone4) { create(:milestone, company_id: company2.id) }

  let!(:investor) { create(:user, password: password, password_confirmation: password, role: :investor, status: :approved )}

  let(:valid_attributes) { { title: "title", description: "description", finish_date: "12-12-2020" } }
  let(:valid_attributes_finish_now) { { title: "title", description: "description", finish_date: DateTime.now } }
  let(:without_title) { { description: "description", finish_date: "12-12-2020" } }
  let(:without_finish_date) { { title: "title", description: "description" } }
  let(:finish_date_in_the_past) { { title: "title", finish_date: "12-12-2018", description: "description" } }
  let(:invalid_completeness) { { title: "title", finish_date: "12-12-2020", description: "description", completeness: 101 } }

  let(:valid_attributes1) { { title: "title1", description: "description1", finish_date: "12-12-2020", completeness: 50, is_done: false } }
  let(:valid_attributes1_finish_now) { { title: "title1", description: "description1", finish_date: DateTime.now, completeness: 50, is_done: false } }

  # Test suite for GET /users/1/companies/1/milestones
  describe 'GET /users/1/companies/1/milestones' do
    context 'when simply get' do
      before do
        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        get "/users/#{user.id}/companies/#{company.id}/milestones", headers: { 'Authorization': token }
      end

      it "return all items" do
        expect(json).not_to be_empty
        expect(json['count']).to eq(3)
        expect(json['items'].size).to eq(3)
      end

      it "return all item info" do
        expect(json['items'][0]["id"]).to be_a_kind_of(Integer)
        expect(json['items'][0]["title"]).to be_a_kind_of(String)
        expect(json['items'][0]["finish_date"]).to be_a_kind_of(String)
        expect(json['items'][0]["description"]).to be_a_kind_of(String)
        expect(json['items'][0]["completeness"]).to be_a_kind_of(Integer)
        expect(json['items'][0]["is_done"]).to be_in([true, false])
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when use limit' do
      before do
        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        get "/users/#{user.id}/companies/#{company.id}/milestones", params: {limit: 2}, headers: { 'Authorization': token }
      end

      it "returns 2 items" do
        expect(json).not_to be_empty
        expect(json['count']).to eq(3)
        expect(json['items'].size).to eq(2)
      end

      it "return all item info" do
        expect(json['items'][0]["id"]).to be_a_kind_of(Integer)
        expect(json['items'][0]["title"]).to be_a_kind_of(String)
        expect(json['items'][0]["finish_date"]).to be_a_kind_of(String)
        expect(json['items'][0]["description"]).to be_a_kind_of(String)
        expect(json['items'][0]["completeness"]).to be_a_kind_of(Integer)
        expect(json['items'][0]["is_done"]).to be_in([true, false])
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when use offset' do
      before do
        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        get "/users/#{user.id}/companies/#{company.id}/milestones", params: {offset: 2}, headers: { 'Authorization': token }
      end

      it "returns response with offset" do
        expect(json).not_to be_empty
        expect(json['count']).to eq(3)
        expect(json['items'].size).to eq(1)
      end

      it "return all item info" do
        expect(json['items'][0]["id"]).to be_a_kind_of(Integer)
        expect(json['items'][0]["title"]).to be_a_kind_of(String)
        expect(json['items'][0]["finish_date"]).to be_a_kind_of(String)
        expect(json['items'][0]["description"]).to be_a_kind_of(String)
        expect(json['items'][0]["completeness"]).to be_a_kind_of(Integer)
        expect(json['items'][0]["is_done"]).to be_in([true, false])
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when i am not startup' do
      before do
        post "/auth/login", params: {email: investor.email, password: password}
        token = json['token']

        get "/users/#{user.id}/companies/#{company.id}/milestones/", headers: {'Authorization': token}
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

        get "/users/#{user2.id}/companies/#{company.id}/milestones/", headers: {'Authorization': token}
      end

      it "returns nothing" do
        expect(response.body).to match("")
      end

      it 'returns status code 403' do
        expect(response).to have_http_status(403)
      end
    end

    context 'when not authorized' do
      before { get "/users/#{user.id}/companies/#{company.id}/milestones/" }

      it 'returns status code 401' do
        expect(response).to have_http_status(401)
      end

      it 'returns a not found message' do
        expect(response.body).to match("")
      end
    end
  end

  # Test suite for GET /users/1/companies/1/milestones/1
  describe 'GET /users/1/companies/1/milestones/1' do
    context 'when the record exists' do
      before do
        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        get "/users/#{user.id}/companies/#{company.id}/milestones/#{milestone.id}", headers: { 'Authorization': token }
      end

      it 'returns the company' do
        expect(json).not_to be_empty
        expect(json['id']).to eq(milestone.id)
      end

      it "return all company info" do
        expect(json["id"]).to eq(milestone.id)
        expect(json["title"]).to eq(milestone.title)
        expect(json["finish_date"]).to be_kind_of(String)
        expect(json["description"]).to eq(milestone.description)
        expect(json["completeness"]).to eq(milestone.completeness)
        expect(json["is_done"]).to eq(milestone.is_done)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when the record does not exist' do
      let(:milestone_id) { 0 }

      before do
        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        get "/users/#{user.id}/companies/#{company.id}/milestones/#{milestone_id}", headers: { 'Authorization': token }
      end

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a not found message' do
        expect(response.body).to match("")
      end
    end

    context 'when i am not startup' do
      before do
        post "/auth/login", params: {email: investor.email, password: password}
        token = json['token']

        get "/users/#{user.id}/companies/#{company.id}/milestones/#{milestone.id}", headers: {'Authorization': token}
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

        get "/users/#{user2.id}/companies/#{company.id}/milestones/#{milestone.id}", headers: {'Authorization': token}
      end

      it "returns nothing" do
        expect(response.body).to match("")
      end

      it 'returns status code 403' do
        expect(response).to have_http_status(403)
      end
    end

    context 'when not my companys item' do
      before do
        post "/auth/login", params: {email: user.email, password: password}
        token = json['token']

        get "/users/#{user.id}/companies/#{company.id}/milestones/#{milestone4.id}", headers: {'Authorization': token}
      end

      it "returns nothing" do
        expect(response.body).to match("")
      end

      it 'returns status code 403' do
        expect(response).to have_http_status(403)
      end
    end

    context 'when not authorized' do
      before { get "/users/#{user.id}/companies/#{company.id}/milestones/#{milestone.id}" }

      it 'returns status code 401' do
        expect(response).to have_http_status(401)
      end

      it 'returns a not found message' do
        expect(response.body).to match("")
      end
    end
  end

  # Test suite for POST /users/1/companies/1/milestones
  describe 'POST /users/1/companies/1/milestones' do
    context 'when the request is valid' do
      before do
        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        post "/users/#{user.id}/companies/#{company.id}/milestones", params: valid_attributes, headers: { 'Authorization': token }
      end

      it 'creates a company item' do
        expect(json["id"]).to be_kind_of(Integer)
        expect(json["title"]).to eq("title")
        expect(json["finish_date"]).to be_kind_of(String)
        expect(json["description"]).to eq("description")
        expect(json["completeness"]).to eq(0)
        expect(json["is_done"]).to eq(false)
      end

      it 'returns status code 201' do
        expect(response).to have_http_status(201)
      end
    end

    context 'when the request is valid with finish date now' do
      before do
        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        post "/users/#{user.id}/companies/#{company.id}/milestones", params: valid_attributes_finish_now, headers: { 'Authorization': token }
      end

      it 'creates a milestone' do
        expect(json["id"]).to be_kind_of(Integer)
        expect(json["title"]).to eq("title")
        expect(json["finish_date"]).to be_kind_of(String)
        expect(json["description"]).to eq("description")
        expect(json["completeness"]).to eq(0)
        expect(json["is_done"]).to eq(false)
      end

      it 'returns status code 201' do
        expect(response).to have_http_status(201)
      end
    end

    context 'when the request without title' do
      before do
        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        post "/users/#{user.id}/companies/#{company.id}/milestones", params: without_title, headers: { 'Authorization': token }
      end

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a validation failure message' do
        expect(response.body)
          .to match("{\"title\":[\"can't be blank\"]}")
      end
    end

    context 'when the request without finish date' do
      before do
        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        post "/users/#{user.id}/companies/#{company.id}/milestones", params: without_finish_date, headers: { 'Authorization': token }
      end

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a validation failure message' do
        expect(response.body)
          .to match("{\"finish_date\":[\"can't be blank\"]}")
      end
    end

    context 'when the request finish date in the past' do
      before do
        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        post "/users/#{user.id}/companies/#{company.id}/milestones", params: finish_date_in_the_past, headers: { 'Authorization': token }
      end

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a validation failure message' do
        expect(response.body)
          .to match("{\"finish_date\":[\"isn't valid\"]}")
      end
    end

    context 'when the request completeness invalid' do
      before do
        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        post "/users/#{user.id}/companies/#{company.id}/milestones", params: invalid_completeness, headers: { 'Authorization': token }
      end

      it 'creates a company item' do
        expect(json["id"]).to be_kind_of(Integer)
        expect(json["title"]).to eq("title")
        expect(json["finish_date"]).to be_kind_of(String)
        expect(json["description"]).to eq("description")
        expect(json["completeness"]).to eq(0)
        expect(json["is_done"]).to eq(false)
      end

      it 'returns status code 201' do
        expect(response).to have_http_status(201)
      end
    end

    context 'when i am not startup' do
      before do
        post "/auth/login", params: { email: investor.email, password: password}
        token = json['token']

        post "/users/#{user.id}/companies/#{company.id}/milestones", params: valid_attributes, headers: { 'Authorization': token }
      end

      it 'returns status code 401' do
        expect(response).to have_http_status(401)
      end

      it 'response is empty' do
        expect(response.body).to match("")
      end
    end

    context 'when not my company' do
      before do
        post "/auth/login", params: {email: user2.email, password: password}
        token = json['token']

        post "/users/#{user2.id}/companies/#{company.id}/milestones", params: valid_attributes, headers: {'Authorization': token}
      end

      it "returns nothing" do
        expect(response.body).to match("")
      end

      it 'returns status code 403' do
        expect(response).to have_http_status(403)
      end
    end

    context 'when the user unauthorized' do
      before do
        post "/users/#{user.id}/companies/#{company.id}/milestones", params: valid_attributes
      end

      it 'returns status code 401' do
        expect(response).to have_http_status(401)
      end

      it 'response is empty' do
        expect(response.body).to match("")
      end
    end
  end

  # Test suite for PATCH /users/1/companies/1/milestones/1
  describe 'PATCH /users/1/companies/1/milestones/1' do
    context 'when the request is valid' do
      before do
        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        patch "/users/#{user.id}/companies/#{company.id}/milestones/#{milestone.id}", params: valid_attributes1, headers: { 'Authorization': token }
      end

      it 'updates a company item' do
        expect(json['id']).to eq(milestone.id)
        expect(json['title']).to eq('title1')
        expect(json['description']).to eq('description1')
        expect(json['finish_date']).to be_kind_of(String)
        expect(json["completeness"]).to eq(50)
        expect(json["is_done"]).to eq(false)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when the request is valid with finish now' do
      before do
        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        patch "/users/#{user.id}/companies/#{company.id}/milestones/#{milestone.id}", params: valid_attributes1_finish_now, headers: { 'Authorization': token }
      end

      it 'updates a milestone' do
        expect(json['id']).to eq(milestone.id)
        expect(json['title']).to eq('title1')
        expect(json['description']).to eq('description1')
        expect(json['finish_date']).to be_kind_of(String)
        expect(json["completeness"]).to eq(50)
        expect(json["is_done"]).to eq(false)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when the request finish date in the past' do
      before do
        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        patch "/users/#{user.id}/companies/#{company.id}/milestones/#{milestone.id}", params: finish_date_in_the_past, headers: { 'Authorization': token }
      end

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a validation failure message' do
        expect(response.body)
          .to match("{\"finish_date\":[\"isn't valid\"]}")
      end
    end

    context 'when already done' do
      before do
        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        milestone.is_done = true
        milestone.save

        patch "/users/#{user.id}/companies/#{company.id}/milestones/#{milestone.id}", params: valid_attributes1, headers: { 'Authorization': token }
      end

      it 'response with error' do
        expect(response.body)
          .to match("{\"errors\":\"MILESTONE_ALREADY_FINISHED\"}")
      end

      it 'returns status code 403' do
        expect(response).to have_http_status(403)
      end
    end

    context 'when the request finish date in the past' do
      before do
        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        patch "/users/#{user.id}/companies/#{company.id}/milestones/#{milestone.id}", params: finish_date_in_the_past, headers: { 'Authorization': token }
      end

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a validation failure message' do
        expect(response.body)
          .to match("{\"finish_date\":[\"isn't valid\"]}")
      end
    end

    context 'when the request with invalid completeness' do
      before do
        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        patch "/users/#{user.id}/companies/#{company.id}/milestones/#{milestone.id}", params: invalid_completeness, headers: { 'Authorization': token }
      end

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a validation failure message' do
        expect(response.body)
          .to match("{\"completeness\":[\"is not included in the list\"]}")
      end
    end

    context 'when does not exists' do
      let(:milestone_id) { 0 }

      before do
        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        patch "/users/#{user.id}/companies/#{company.id}/milestones/#{milestone_id}", params: valid_attributes1, headers: { 'Authorization': token }
      end

      it 'response is empty' do
        expect(response.body).to match("")
      end

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end
    end

    context 'when not my company' do
      before do
        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        patch "/users/#{user.id}/companies/#{company2.id}/milestones/#{milestone.id}", params: valid_attributes1, headers: { 'Authorization': token }
      end

      it 'returns status code 403' do
        expect(response).to have_http_status(403)
      end

      it 'response is empty' do
        expect(response.body).to match("")
      end
    end

    context 'when not my company item' do
      before do
        post "/auth/login", params: { email: user.email, password: password}
        token = json['token']

        patch "/users/#{user.id}/companies/#{company.id}/milestones/#{milestone4.id}", params: valid_attributes1, headers: { 'Authorization': token }
      end

      it 'returns status code 403' do
        expect(response).to have_http_status(403)
      end

      it 'response is empty' do
        expect(response.body).to match("")
      end
    end

    context 'when i am not startup' do
      before do
        post "/auth/login", params: { email: investor.email, password: password}
        token = json['token']

        patch "/users/#{user.id}/companies/#{company.id}/milestones/#{milestone.id}", params: valid_attributes1, headers: { 'Authorization': token }
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
        patch "/users/#{user.id}/companies/#{company.id}/milestones/#{milestone.id}", params: valid_attributes1
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

require 'rails_helper'

RSpec.describe "CompanyItems", type: :request do
  describe "GET /company_items" do
    it "works! (now write some real specs)" do
      get company_items_path
      expect(response).to have_http_status(200)
    end
  end
end

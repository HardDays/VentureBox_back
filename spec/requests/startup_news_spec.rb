require 'rails_helper'

RSpec.describe "StartupNews", type: :request do
  describe "GET /startup_news" do
    it "works! (now write some real specs)" do
      get startup_news_index_path
      expect(response).to have_http_status(200)
    end
  end
end

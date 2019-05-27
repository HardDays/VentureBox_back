require "rails_helper"

RSpec.describe InvestedCompaniesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(:get => "/invested_companies").to route_to("invested_companies#index")
    end

    it "routes to #my_investors" do
      expect(:get => "/users/1/companies/1/investors").to route_to("invested_companies#my_investors", :user_id => "1", :id => "1")
    end

    it "routes to #show" do
      expect(:get => "/invested_companies/1").not_to be_routable
    end


    it "routes to #create" do
      expect(:post => "/companies/1/invested_companies").to route_to("invested_companies#create", :id => "1")
    end

    it "routes to #update via PUT" do
      expect(:put => "/invested_companies/1").not_to be_routable
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/invested_companies/1").not_to be_routable
    end

    it "routes to #destroy" do
      expect(:delete => "/invested_companies/1").not_to be_routable
    end
  end
end

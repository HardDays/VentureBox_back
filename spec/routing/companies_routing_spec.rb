require "rails_helper"

RSpec.describe CompaniesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(:get => "/companies").to route_to("companies#index")
    end

    it "routes to #show" do
      expect(:get => "/companies/1").to route_to("companies#show", :id => "1")
    end

    it "routes to #my" do
      expect(:get => "users/1/companies/1").to route_to("companies#my", :id => "1", :user_id => "1")
    end

    it "routes to #create" do
      expect(:post => "/users/1/companies").to route_to("companies#create", :user_id => "1")
    end

    it "routes to #update via PUT" do
      expect(:put => "/users/1/companies/1").to route_to("companies#update", :user_id => "1", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/users/1/companies/1").to route_to("companies#update", :user_id => "1", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/users/1/companies/1").to route_to("companies#destroy", :user_id => "1", :id => "1")
    end
  end
end

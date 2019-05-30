require "rails_helper"

RSpec.describe CompaniesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(:get => "/companies").to route_to("companies#index")
    end

    it "routes to #show" do
      expect(:get => "/companies/1").to route_to("companies#show", :id => "1")
    end

    it "routes to #show" do
      expect(:get => "/companies/1/image").to route_to("companies#image", :id => "1")
    end

    it "routes to #investor_companies" do
      expect(:get => "/companies/my").to route_to("companies#investor_companies")
    end


    it "routes to #my" do
      expect(:get => "/users/1/companies/1").to route_to("companies#my", :user_id => "1", :id => "1")
    end

    it "routes to #my_image" do
      expect(:get => "/users/1/companies/1/image").to route_to("companies#my_image", :id => "1", :user_id => "1")
    end

    it "routes to #create" do
      expect(:post => "/users/1/companies").not_to be_routable
    end

    it "routes to #update via PUT" do
      expect(:put => "/users/1/companies/1").to route_to("companies#update", :user_id => "1", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/users/1/companies/1").to route_to("companies#update", :user_id => "1", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/users/1/companies/1").not_to be_routable
    end
  end
end

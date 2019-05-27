require "rails_helper"

RSpec.describe InterestingCompaniesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(:get => "/interesting_companies").to route_to("interesting_companies#index")
    end

    it "routes to #show" do
      expect(:get => "/interesting_companies/1").not_to be_routable
    end


    it "routes to #create" do
      expect(:post => "/companies/1/interesting_companies").to route_to("interesting_companies#create", :id => "1")
    end

    it "routes to #update via PUT" do
      expect(:put => "/interesting_companies/1").not_to be_routable
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/interesting_companies/1").not_to be_routable
    end

    it "routes to #destroy" do
      expect(:delete => "/interesting_companies/1").to route_to("interesting_companies#destroy", :id => "1")
    end
  end
end

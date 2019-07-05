require "rails_helper"

RSpec.describe TrackingController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(:get => "/users/1/companies/1/startup_graphics").not_to be_routable
    end

    it "routes to #show" do
      expect(:get => "/users/1/companies/1/startup_graphics/1").not_to be_routable
    end

    it "routes to #create" do
      expect(:post => "/users/1/companies/1/startup_graphics").not_to be_routable
    end

    it "routes to #update via PUT" do
      expect(:put => "/users/1/companies/1/startup_graphics/1").not_to be_routable
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/users/1/companies/1/startup_graphics/1").not_to be_routable
    end

    it "routes to #destroy" do
      expect(:delete => "/users/1/companies/1/startup_graphics/1").not_to be_routable
    end


    it "routes to #startup" do
      expect(:get => "/tracking/startup").to route_to("tracking#startup")
    end
    it "routes to #investor" do
      expect(:get => "/tracking/investor").to route_to("tracking#investor")
    end
  end
end


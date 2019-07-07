require "rails_helper"

RSpec.describe TrackingController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(:get => "/tracking").not_to be_routable
    end

    it "routes to #show" do
      expect(:get => "/tracking/1").not_to be_routable
    end

    it "routes to #create" do
      expect(:post => "/tracking").not_to be_routable
    end

    it "routes to #update via PUT" do
      expect(:put => "/tracking/1").not_to be_routable
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/tracking/1").not_to be_routable
    end

    it "routes to #destroy" do
      expect(:delete => "/tracking/1").not_to be_routable
    end


    it "routes to #startup" do
      expect(:get => "/tracking/startup").to route_to("tracking#startup")
    end

    it "routes to #investor" do
      expect(:get => "/tracking/investor").to route_to("tracking#investor")
    end

    it "routes to #investor" do
      expect(:post => "/tracking/mark_payed").to route_to("tracking#mark_payed")
    end
  end
end


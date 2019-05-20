require "rails_helper"

RSpec.describe RequestsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(:get => "/requests").not_to be_routable
    end

    it "routes to #show" do
      expect(:get => "/requests/1").not_to be_routable
    end


    it "routes to #create" do
      expect(:post => "/requests").to route_to("requests#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/requests/1").not_to be_routable
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/requests/1").not_to be_routable
    end

    it "routes to #destroy" do
      expect(:delete => "/requests/1").not_to be_routable
    end
  end
end

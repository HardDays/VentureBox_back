require "rails_helper"

RSpec.describe EnumsController, type: :routing do
  describe "routing" do
    it "routes to #c_level" do
      expect(:get => "/enums/c_level").to route_to("enums#c_level")
    end

    it "routes to #stage_of_funding" do
      expect(:get => "/enums/stage_of_funding").to route_to("enums#stage_of_funding")
    end

    it "routes to #tags" do
      expect(:get => "/enums/tags").to route_to("enums#tags")
    end

    it "routes to #countries" do
      expect(:get => "/enums/countries").to route_to("enums#countries")
    end


    it "routes to #index" do
      expect(:get => "/enums").not_to be_routable
    end

    it "routes to #show" do
      expect(:get => "/enums/1").not_to be_routable
    end

    it "routes to #create" do
      expect(:post => "/enums").not_to be_routable
    end

    it "routes to #update via PUT" do
      expect(:put => "/enums/1").not_to be_routable
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/enums/1").not_to be_routable
    end

    it "routes to #destroy" do
      expect(:delete => "/enums/11").not_to be_routable
    end
  end
end

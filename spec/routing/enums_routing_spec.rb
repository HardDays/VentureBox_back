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
  end
end

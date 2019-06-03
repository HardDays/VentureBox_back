require "rails_helper"

RSpec.describe InvestorGraphicsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(:get => "/users/1/investor_graphics").not_to be_routable
    end

    it "routes to #show" do
      expect(:get => "/users/1/investor_graphics/1").not_to be_routable
    end

    it "routes to #create" do
      expect(:post => "/users/1/investor_graphics").not_to be_routable
    end

    it "routes to #update via PUT" do
      expect(:put => "/users/1/investor_graphics/1").not_to be_routable
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/users/1/investor_graphics/1").not_to be_routable
    end

    it "routes to #destroy" do
      expect(:delete => "/users/1/investor_graphics/1").not_to be_routable
    end

    it "routes to #sales" do
      expect(:get => "/users/1/investor_graphics/total_current_value").to route_to("investor_graphics#total_current_value", :user_id => "1")
    end

    it "routes to #total_earn" do
      expect(:get => "/users/1/investor_graphics/amount_of_companies").to route_to("investor_graphics#amount_of_companies", :user_id => "1")
    end

    it "routes to #total_investment" do
      expect(:get => "/users/1/investor_graphics/amount_invested").to route_to("investor_graphics#amount_invested", :user_id => "1")
    end

    it "routes to #score" do
      expect(:get => "/users/1/investor_graphics/rate_of_return").to route_to("investor_graphics#rate_of_return", :user_id => "1")
    end
  end
end

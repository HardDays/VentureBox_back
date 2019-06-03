require "rails_helper"

RSpec.describe StartupGraphicsController, type: :routing do
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

    it "routes to #sales" do
      expect(:get => "/users/1/companies/1/startup_graphics/sales").to route_to("startup_graphics#sales", :user_id => "1", :company_id => "1")
    end

    it "routes to #total_earn" do
      expect(:get => "/users/1/companies/1/startup_graphics/total_earn").to route_to("startup_graphics#total_earn", :user_id => "1", :company_id => "1")
    end

    it "routes to #total_investment" do
      expect(:get => "/users/1/companies/1/startup_graphics/total_investment").to route_to("startup_graphics#total_investment", :user_id => "1", :company_id => "1")
    end

    it "routes to #score" do
      expect(:get => "/users/1/companies/1/startup_graphics/score").to route_to("startup_graphics#score", :user_id => "1", :company_id => "1")
    end

    it "routes to #evaluation" do
      expect(:get => "/users/1/companies/1/startup_graphics/evaluation").to route_to("startup_graphics#evaluation", :user_id => "1", :company_id => "1")
    end
  end
end

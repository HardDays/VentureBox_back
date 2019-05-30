require "rails_helper"

RSpec.describe StartupNewsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(:get => "/startup_news").to route_to("startup_news#index")
    end

    it "routes to #show" do
      expect(:get => "/startup_news/1").to route_to("startup_news#show", :id => "1")
    end

    it "routes to #companies_news" do
      expect(:get => "/companies/1/company_news").to route_to("startup_news#company_news", :id => "1")
    end


    it "routes to #index" do
      expect(:get => "/users/1/companies/1/startup_news").to route_to("startup_news#my_news", :user_id => "1", :company_id => "1")
    end

    it "routes to #show" do
      expect(:get => "/users/1/companies/1/startup_news/1").to route_to("startup_news#my", :id => "1", :user_id => "1", :company_id => "1")
    end

    it "routes to #create" do
      expect(:post => "/users/1/companies/1/startup_news").to route_to("startup_news#create", :user_id => "1", :company_id => "1")
    end

    it "routes to #update via PUT" do
      expect(:put => "/startup_news/1").not_to be_routable
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/startup_news/1").not_to be_routable
    end

    it "routes to #update via PUT" do
      expect(:put => "/users/1/companies/1/startup_news/1").not_to be_routable
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/users/1/companies/1/startup_news/1").not_to be_routable
    end

    it "routes to #destroy" do
      expect(:delete => "/users/1/companies/1/startup_news/1").to route_to("startup_news#destroy", :id => "1", :user_id => "1", :company_id => "1")
    end
  end
end

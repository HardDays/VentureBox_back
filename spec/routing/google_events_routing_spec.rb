require "rails_helper"

RSpec.describe GoogleEventsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(:get => "/users/1/companies/1/google_events").to route_to("google_events#index", :user_id => "1", :company_id => "1")
    end

    it "routes to #show" do
      expect(:get => "/users/1/companies/1/google_events/1").not_to be_routable
    end

    it "routes to #create" do
      expect(:post => "/users/1/companies/1/google_events").to route_to("google_events#create", :user_id => "1", :company_id => "1")
    end

    it "routes to #set_google_calendar" do
      expect(:post => "/users/1/companies/1/google_events/set_google_calendar").to route_to("google_events#set_google_calendar", :user_id => "1", :company_id => "1")
    end

    it "routes to #update via PUT" do
      expect(:put => "/users/1/companies/1/google_events/1").not_to be_routable
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/users/1/companies/1/google_events/1").not_to be_routable
    end

    it "routes to #destroy" do
      expect(:delete => "/users/1/companies/1/google_events/1").not_to be_routable
    end
  end
end

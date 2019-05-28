require "rails_helper"

RSpec.describe MilestonesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(:get => "/users/1/companies/1/milestones").to route_to("milestones#index", :user_id => "1", :company_id => "1")
    end

    it "routes to #show" do
      expect(:get => "/users/1/companies/1/milestones/1").to route_to("milestones#show", :id => "1", :user_id => "1", :company_id => "1")
    end


    it "routes to #create" do
      expect(:post => "/users/1/companies/1/milestones").to route_to("milestones#create", :user_id => "1", :company_id => "1")
    end

    it "routes to #update via PUT" do
      expect(:put => "/users/1/companies/1/milestones/1").to route_to("milestones#update", :id => "1", :user_id => "1", :company_id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/users/1/companies/1/milestones/1").to route_to("milestones#update", :id => "1", :user_id => "1", :company_id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/users/1/companies/1/milestones/1").not_to be_routable
    end
  end
end

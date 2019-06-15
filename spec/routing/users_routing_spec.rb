require "rails_helper"

RSpec.describe UsersController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(:get => "/users").not_to be_routable
    end

    it "routes to #me" do
      expect(:get => "/users/me").to route_to("users#me")
    end


    it "routes to #create" do
      expect(:post => "/users").to route_to("users#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/users/1").not_to be_routable
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/users/1").not_to be_routable
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/users/1/change_password").to route_to("users#change_password", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/users/1/change_email").to route_to("users#change_email", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/users/1/change_general").to route_to("users#change_general", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/users/1").to route_to("users#destroy", :id => "1")
    end
  end
end

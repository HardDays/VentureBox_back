require "rails_helper"

RSpec.describe CompanyItemsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(:get => "/company_items").to route_to("company_items#index")
    end

    it "routes to #show" do
      expect(:get => "/company_items/1").to route_to("company_items#show", :id => "1")
    end

    it "routes to #item_image" do
      expect(:get => "/company_items/1/image").to route_to("company_items#item_image", :id => "1")
    end

    it "routes to #company_items" do
      expect(:get => "/companies/1/company_items").to route_to("company_items#company_items", :id => "1")
    end


    it "routes to #my_items" do
      expect(:get => "/users/1/companies/1/company_items").to route_to("company_items#my_items", :user_id => "1", :company_id => "1")
    end

    it "routes to #my_item" do
      expect(:get => "/users/1/companies/1/company_items/1").to route_to("company_items#my_item", :id => "1", :user_id => "1", :company_id => "1")
    end

    it "routes to #my_item_image" do
      expect(:get => "/users/1/companies/1/company_items/1/image").to route_to("company_items#my_item_image", :id => "1", :user_id => "1", :company_id => "1")
    end

    it "routes to #create" do
      expect(:post => "/users/1/companies/1/company_items").to route_to("company_items#create", :user_id => "1", :company_id => "1")
    end

    it "routes to #update via PUT" do
      expect(:put => "/users/1/companies/1/company_items/1").to route_to("company_items#update", :id => "1", :user_id => "1", :company_id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/users/1/companies/1/company_items/1").to route_to("company_items#update", :id => "1", :user_id => "1", :company_id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/users/1/companies/1/company_items/1").to route_to("company_items#destroy", :id => "1", :user_id => "1", :company_id => "1")
    end
  end
end

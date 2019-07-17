
require "rails_helper"

RSpec.describe InvestorGraphicsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(:get => "/shopify_hooks").not_to be_routable
    end

    it "routes to #show" do
      expect(:get => "/shopify_hooks/1").not_to be_routable
    end

    it "routes to #create" do
      expect(:post => "/shopify_hooks").not_to be_routable
    end

    it "routes to #update via PUT" do
      expect(:put => "/shopify_hooks/1").not_to be_routable
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/shopify_hooks/1").not_to be_routable
    end

    it "routes to #destroy" do
      expect(:delete => "/shopify_hooks/1").not_to be_routable
    end

    it "routes to #order_create" do
      expect(:post => "/shopify_hooks/order_create").to route_to("shopify_hooks#order_create")
    end

    it "routes to #order_refund" do
      expect(:post => "/shopify_hooks/order_refund").to route_to("shopify_hooks#order_refund")
    end
  end
end

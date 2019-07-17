class ShopifyHooksController < ApplicationController

  # GET /shopify_hooks/order_create
  # Webhook for Shopify on event OrderCreate
  #
  # request
  #
  # {
  #   <...>
  #   "line_items": [
  #     {
  #       <...>
  #       "product_id": #{company_item.shopify_id},
  #       <...>
  #       "price": "199.00",
  #       <...>
  #     },
  #     <...>
  #   ],
  #   <...>
  # }
  def order_create
    print request.body.read
    print request.raw_post
    render status: :ok
  end

  def order_refund

  end
end

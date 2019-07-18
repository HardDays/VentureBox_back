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
    data = request.body.read

    unless verify_webhook(data, request.headers["X-Shopify-Hmac-Sha256"])
      print request.headers["X-Shopify-Hmac-Sha256"]
      render status: :forbidden and return
    end

    data = JSON.parse data
    unless "line_items".in? data
      print data
      render status: :unprocessable_entity and return
    end

    order_date = data["updated_at"]
    data["line_items"].each do |line_item|
      @company_item = CompanyItem.find_by(shopify_id: line_item["product_id"])

      orders_sum_price = ShopifyOrdersSumm.where(company: @company_item.company).sum(:price)
      begin
        @shopify_orders_summ = ShopifyOrdersSumm.find_by(
          company: @company_item.company,
          date: DateTime.parse(order_date).utc.beginning_of_day
        )

        price = @shopify_orders_summ.price.to_f + line_item["price"].to_f
        @shopify_orders_summ.update(price: price + orders_sum_price)
      rescue
        ShopifyOrdersSumm.create!(
          company: @company_item.company,
          date: DateTime.parse(order_date),
          price: line_item["price"].to_f + orders_sum_price
        )
      end

      begin
        @shopify_orders_count = ShopifyOrdersCount.find_by(
          company_item: @company_item
        )

        @shopify_orders_count.update(count: @shopify_orders_count + 1)
      rescue
        ShopifyOrdersCount.create!(
          company_item: @company_item,
          date: DateTime.parse(order_date),
          count: 1
        )
      end
    end

    render status: :ok
  end

  def order_refund

  end

  private
  def verify_webhook(data, hmac_header)
    calculated_hmac = Base64.strict_encode64(OpenSSL::HMAC.digest('sha256', ENV['SHOPIFY_WEBHOOK'], data))
    ActiveSupport::SecurityUtils.secure_compare(calculated_hmac, hmac_header)
  end
end

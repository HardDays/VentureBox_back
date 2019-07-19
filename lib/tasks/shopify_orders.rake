namespace :shopify_orders do
  desc "Collect orders sum"
  task :collect => :environment do
    updated_at_min = DateTime.now.utc.prev_day.beginning_of_day

    exchange = ShopifyExchange.new
    exchange.calculate_orders_sum(updated_at_min)
  end
end

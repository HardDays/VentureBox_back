class ChangePriceToShopifyOrdersSumms < ActiveRecord::Migration[5.2]
  def change
    change_column :shopify_orders_summs, :price, :integer, using: 'price::integer'
  end
end

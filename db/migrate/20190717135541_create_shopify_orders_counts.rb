class CreateShopifyOrdersCounts < ActiveRecord::Migration[5.2]
  def change
    create_table :shopify_orders_counts do |t|
      t.integer :company_item_id
      t.integer :count
      t.datetime :date

      t.timestamps
    end
  end
end

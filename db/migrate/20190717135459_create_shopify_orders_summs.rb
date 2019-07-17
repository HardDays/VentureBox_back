class CreateShopifyOrdersSumms < ActiveRecord::Migration[5.2]
  def change
    create_table :shopify_orders_summs do |t|
      t.integer :company_id
      t.string :price
      t.datetime :date

      t.timestamps
    end
  end
end

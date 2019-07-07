class AddProductIdToCompanyItem < ActiveRecord::Migration[5.2]
  def change
    add_column :company_items, :shopify_id, :string
    add_column :company_items, :link_to_store, :string
  end
end

class AddCountryToCompanyItems < ActiveRecord::Migration[5.2]
  def change
    add_column :company_items, :country_id, :integer
    add_column :company_items, :product_type, :string

    remove_column :company_items, :is_physical, :boolean
    remove_column :company_items, :weight, :integer
    remove_column :company_items, :weight_unit, :integer
    remove_column :company_items, :link_to_store, :string
  end
end

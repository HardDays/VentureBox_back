class AddShipingToCompanyProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :company_items, :is_physical, :boolean
    add_column :company_items, :weight, :integer
    add_column :company_items, :weight_unit, :integer
  end
end

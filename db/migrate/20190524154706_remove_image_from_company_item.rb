class RemoveImageFromCompanyItem < ActiveRecord::Migration[5.2]
  def change
    remove_column :company_items, :image
  end
end

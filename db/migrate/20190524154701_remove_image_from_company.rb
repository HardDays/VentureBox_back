class RemoveImageFromCompany < ActiveRecord::Migration[5.2]
  def change
    remove_column :companies, :image
  end
end

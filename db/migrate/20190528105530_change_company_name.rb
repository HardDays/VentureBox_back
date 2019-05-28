class ChangeCompanyName < ActiveRecord::Migration[5.2]
  def change
    rename_column :companies, :name, :company_name
  end
end

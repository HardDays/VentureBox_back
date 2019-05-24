class AddLogoAndEmailToCompany < ActiveRecord::Migration[5.2]
  def change
    add_column :companies, :image, :string
    add_column :companies, :contact_email, :string
  end
end

class CreateCompanyItemImages < ActiveRecord::Migration[5.2]
  def change
    create_table :company_item_images do |t|
      t.integer :company_item_id
      t.string :base64

      t.timestamps
    end
  end
end

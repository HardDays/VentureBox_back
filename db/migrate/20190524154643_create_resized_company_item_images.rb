class CreateResizedCompanyItemImages < ActiveRecord::Migration[5.2]
  def change
    create_table :resized_company_item_images do |t|
      t.integer :company_item_image_id
      t.string :base64
      t.integer :width
      t.integer :height

      t.timestamps
    end
  end
end

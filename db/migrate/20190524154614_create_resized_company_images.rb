class CreateResizedCompanyImages < ActiveRecord::Migration[5.2]
  def change
    create_table :resized_company_images do |t|
      t.integer :company_image_id
      t.string :base64
      t.integer :width
      t.integer :height

      t.timestamps
    end
  end
end

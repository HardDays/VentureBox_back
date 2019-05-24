class CreateCompanyImages < ActiveRecord::Migration[5.2]
  def change
    create_table :company_images do |t|
      t.integer :company_id
      t.string :base64

      t.timestamps
    end
  end
end

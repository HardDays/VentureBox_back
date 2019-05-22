class CreateCompanyItems < ActiveRecord::Migration[5.2]
  def change
    create_table :company_items do |t|
      t.integer :company_id
      t.string :image
      t.string :name
      t.string :price
      t.string :link_to_store
      t.string :description

      t.timestamps
    end
  end
end

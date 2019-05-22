class CreateCompanyItemTags < ActiveRecord::Migration[5.2]
  def change
    create_table :company_item_tags do |t|
      t.integer :company_item_id
      t.integer :tag

      t.timestamps
    end
  end
end

class CreateStartupNews < ActiveRecord::Migration[5.2]
  def change
    create_table :startup_news do |t|
      t.integer :company_id
      t.string :text

      t.timestamps
    end
  end
end

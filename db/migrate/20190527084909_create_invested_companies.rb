class CreateInvestedCompanies < ActiveRecord::Migration[5.2]
  def change
    create_table :invested_companies do |t|
      t.integer :investor_id
      t.integer :company_id
      t.string :contact_email
      t.integer :investment
      t.integer :evaluation

      t.timestamps
    end
  end
end

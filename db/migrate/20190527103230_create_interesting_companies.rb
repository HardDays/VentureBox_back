class CreateInterestingCompanies < ActiveRecord::Migration[5.2]
  def change
    create_table :interesting_companies do |t|
      t.integer :investor_id
      t.integer :company_id

      t.timestamps
    end
  end
end

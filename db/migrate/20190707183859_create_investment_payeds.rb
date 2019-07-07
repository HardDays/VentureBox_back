class CreateInvestmentPayeds < ActiveRecord::Migration[5.2]
  def change
    create_table :investment_payeds do |t|
      t.integer :amount
      t.integer :invested_company_id
      t.datetime :date

      t.timestamps
    end
  end
end

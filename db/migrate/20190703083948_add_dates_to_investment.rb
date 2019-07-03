class AddDatesToInvestment < ActiveRecord::Migration[5.2]
  def change
    add_column :invested_companies, :date_from, :datetime
    add_column :invested_companies, :date_to, :datetime
  end
end

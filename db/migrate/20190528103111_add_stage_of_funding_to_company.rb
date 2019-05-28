class AddStageOfFundingToCompany < ActiveRecord::Migration[5.2]
  def change
    add_column :companies, :stage_of_funding, :integer
    add_column :companies, :investment_amount, :integer
    add_column :companies, :equality_amount, :integer
  end
end

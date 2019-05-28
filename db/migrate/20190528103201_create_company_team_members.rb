class CreateCompanyTeamMembers < ActiveRecord::Migration[5.2]
  def change
    create_table :company_team_members do |t|
      t.integer :company_id
      t.string :team_member_name
      t.integer :c_level

      t.timestamps
    end
  end
end

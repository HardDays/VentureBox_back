class CreateMilestones < ActiveRecord::Migration[5.2]
  def change
    create_table :milestones do |t|
      t.string :title
      t.string :description
      t.datetime :finish_date
      t.integer :completeness, default: 0
      t.integer :company_id
      t.boolean :is_done, default: false

      t.timestamps
    end
  end
end

class CreateRequests < ActiveRecord::Migration[5.2]
  def change
    create_table :requests do |t|
      t.string :name
      t.string :email
      t.string :requested_name
      t.integer :interested_in

      t.timestamps
    end
  end
end

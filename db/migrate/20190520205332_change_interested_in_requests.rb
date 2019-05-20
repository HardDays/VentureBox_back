class ChangeInterestedInRequests < ActiveRecord::Migration[5.2]
  def change
    remove_column :requests, :interested_in
    add_column :requests, :interested_in_investing, :boolean, default: false
    add_column :requests, :interested_in_advisor, :boolean, default: false
    add_column :requests, :interested_in_purchasing, :boolean, default: false

  end
end

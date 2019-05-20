class AddIsEmailNotificationsAvailableToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :is_email_notifications_available, :boolean, default: false
  end
end

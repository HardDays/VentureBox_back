class AddEspoUserIdToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :espo_user_id, :string
  end
end

class RemoveOldUserIdColumns < ActiveRecord::Migration[8.1]
  def change
    remove_column :alarms, :user_id, :bigint
    remove_column :bookmarks, :user_id, :bigint
    remove_column :friendships, :user_id, :bigint
    remove_column :friendships, :friend_id, :bigint
    remove_column :message_templates, :user_id, :bigint

    remove_column :users, :id, :bigint
  end
end

class ChangeUsersPrimaryKeyToUuid < ActiveRecord::Migration[8.1]
  def change
    remove_foreign_key :alarms, :users
    remove_foreign_key :bookmarks, :users
    remove_foreign_key :friendships, :users
    remove_foreign_key :friendships, column: :friend_id

    if foreign_key_exists?(:message_templates, :users)
      remove_foreign_key :message_templates, :users
    end

    execute 'ALTER TABLE users DROP CONSTRAINT users_pkey;'
    execute 'ALTER TABLE users ADD PRIMARY KEY (uuid);'

    add_foreign_key :alarms, :users, column: :user_uuid, primary_key: :uuid
    add_foreign_key :bookmarks, :users, column: :user_uuid, primary_key: :uuid
    add_foreign_key :friendships, :users, column: :user_uuid, primary_key: :uuid
    add_foreign_key :friendships, :users, column: :friend_uuid, primary_key: :uuid
    add_foreign_key :message_templates, :users, column: :user_uuid, primary_key: :uuid
  end
end

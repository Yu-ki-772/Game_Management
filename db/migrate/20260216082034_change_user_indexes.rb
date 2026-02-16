class ChangeUserIndexes < ActiveRecord::Migration[8.1]
  def change
    remove_index :alarms, name: 'index_alarms_on_user_id'
    add_index :alarms, :user_uuid

    remove_index :bookmarks, name: 'index_bookmarks_on_user_id'
    add_index :bookmarks, :user_uuid

    remove_index :bookmarks, name: 'index_bookmarks_on_user_id_and_message_template_id'
    add_index :bookmarks, [:user_uuid, :message_template_id], 
              unique: true, 
              name: 'index_bookmarks_on_user_uuid_and_message_template_id'

    remove_index :friendships, name: 'index_friendships_on_user_id'
    remove_index :friendships, name: 'index_friendships_on_friend_id'
    add_index :friendships, :user_uuid
    add_index :friendships, :friend_uuid

    remove_index :friendships, name: 'index_friendships_on_user_id_and_friend_id'
    add_index :friendships, [:user_uuid, :friend_uuid], 
              unique: true, 
              name: 'index_friendships_on_user_uuid_and_friend_uuid'

    remove_index :message_templates, name: 'index_message_templates_on_user_id'
    add_index :message_templates, :user_uuid
  end
end

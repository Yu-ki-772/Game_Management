class AddUserUuidToRelatedTables < ActiveRecord::Migration[8.1]
  def change
    add_column :alarms, :user_uuid, :uuid
    add_column :bookmarks, :user_uuid, :uuid
    add_column :friendships, :user_uuid, :uuid
    add_column :friendships, :friend_uuid, :uuid
    add_column :message_templates, :user_uuid, :uuid

    Alarm.reset_column_information
    Alarm.find_each do |alarm|
      alarm.update_column(:user_uuid, User.find(alarm.user_id).uuid)
    end

    Bookmark.reset_column_information
    Bookmark.find_each do |bookmark|
      bookmark.update_column(:user_uuid, User.find(bookmark.user_id).uuid)
    end

    Friendship.reset_column_information
    Friendship.find_each do |friendship|
      friendship.update_column(:user_uuid, User.find(friendship.user_id).uuid)
      friendship.update_column(:friend_uuid, User.find(friendship.friend_id).uuid)
    end

    MessageTemplate.reset_column_information
    MessageTemplate.find_each do |template|
      if template.user_id.present?
        template.update_column(:user_uuid, User.find(template.user_id).uuid)
      end
    end

    change_column_null :alarms, :user_uuid, false

    change_column_null :friendships, :user_uuid, false
    change_column_null :friendships, :friend_uuid, false
  end
end

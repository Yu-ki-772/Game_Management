class ChangeWebPushSubscriptionsUniqueConstraint < ActiveRecord::Migration[8.1]
  def change
    remove_index :web_push_subscriptions, :endpoint
    add_index :web_push_subscriptions, [:endpoint, :user_uuid], unique: true
  end
end

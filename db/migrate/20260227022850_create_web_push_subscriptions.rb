class CreateWebPushSubscriptions < ActiveRecord::Migration[8.1]
  def change
    create_table :web_push_subscriptions do |t|
      t.uuid :user_uuid, null: false
      t.text :endpoint,  null: false
      t.text :p256dh,    null: false
      t.text :auth,      null: false

      t.timestamps
    end

    add_index :web_push_subscriptions, :user_uuid
    add_index :web_push_subscriptions, :endpoint, unique: true

    add_foreign_key :web_push_subscriptions, :users, column: :user_uuid, primary_key: :uuid
  end
end

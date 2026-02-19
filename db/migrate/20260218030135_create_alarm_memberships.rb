class CreateAlarmMemberships < ActiveRecord::Migration[8.1]
  def change
    create_table :alarm_memberships do |t|
      t.uuid :user_uuid, null: false
      t.uuid :alarm_uuid, null: false

      t.timestamps
    end

    add_foreign_key :alarm_memberships, :users,  column: "user_uuid",  primary_key: "uuid"
    add_foreign_key :alarm_memberships, :alarms, column: "alarm_uuid", primary_key: "uuid"

    add_index :alarm_memberships, :user_uuid
    add_index :alarm_memberships, :alarm_uuid
  end
end

class AddUserUuidToAlarmLogs < ActiveRecord::Migration[8.1]
  def change
    add_column :alarm_logs, :user_uuid, :uuid

    add_foreign_key :alarm_logs, :users, column: :user_uuid, primary_key: :uuid
    
    add_index :alarm_logs, :user_uuid
  end
end

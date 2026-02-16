class ChangeAlarmIndexes < ActiveRecord::Migration[8.1]
  def change
    remove_index :alarm_logs, name: 'index_alarm_logs_on_alarm_id'
    add_index :alarm_logs, :alarm_uuid
  end
end

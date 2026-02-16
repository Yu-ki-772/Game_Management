class RemoveOldAlarmIdColumns < ActiveRecord::Migration[8.1]
  def change
    remove_column :alarm_logs, :alarm_id, :bigint
    remove_column :alarms, :id, :bigint
  end
end

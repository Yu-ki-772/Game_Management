class AddAlarmUuidToAlarmLogs < ActiveRecord::Migration[8.1]
  def change
    add_column :alarm_logs, :alarm_uuid, :uuid

    AlarmLog.reset_column_information
    AlarmLog.find_each do |log|
      log.update_column(:alarm_uuid, Alarm.find(log.alarm_id).uuid)
    end

    change_column_null :alarm_logs, :alarm_uuid, false
  end
end

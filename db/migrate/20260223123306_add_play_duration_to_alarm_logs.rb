class AddPlayDurationToAlarmLogs < ActiveRecord::Migration[8.1]
  def change
    add_column :alarm_logs, :play_duration, :integer
  end
end

class RenameUnlockColumnsToStop < ActiveRecord::Migration[8.1]
  def change
    rename_column :alarms, :unlocked, :stopped

    rename_column :alarm_logs, :unlocked_at, :stopped_at
    rename_column :alarm_logs, :minutes_to_unlock, :minutes_to_stop
  end
end

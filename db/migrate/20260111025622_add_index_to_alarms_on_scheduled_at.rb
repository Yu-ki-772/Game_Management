class AddIndexToAlarmsOnScheduledAt < ActiveRecord::Migration[8.1]
  def change
    add_index :alarms, :scheduled_at
  end
end

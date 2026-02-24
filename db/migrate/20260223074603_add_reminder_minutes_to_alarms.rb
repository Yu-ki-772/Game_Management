class AddReminderMinutesToAlarms < ActiveRecord::Migration[8.1]
  def change
    add_column :alarms, :reminder_minutes, :integer
    add_column :alarms, :reminder_job_id, :string
  end
end

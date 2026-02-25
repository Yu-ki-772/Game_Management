class RenamePreNotificationJobIdToReminderJobIdInAlarms < ActiveRecord::Migration[8.1]
  def change
    rename_column :alarms, :pre_notification_job_id, :reminder_job_id
  end
end

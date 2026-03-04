class RemoveNotifiedAtColumnsFromAlarmMemberships < ActiveRecord::Migration[8.1]
  def change
    remove_column :alarm_memberships, :notified_at, :boolean, if_exists: true
    remove_column :alarm_memberships, :reminder_notified_at, :boolean, if_exists: true
  end
end

class AddNotifiedToAlarmMemberships < ActiveRecord::Migration[8.1]
  def change
    add_column :alarm_memberships, :notified, :boolean, default: false, null: false
    add_column :alarm_memberships, :reminder_notified, :boolean, default: false, null: false
  end
end

class ChangeAlarmsPrimaryKeyToUuid < ActiveRecord::Migration[8.1]
  def change
    remove_foreign_key :alarm_logs, :alarms

    execute 'ALTER TABLE alarms DROP CONSTRAINT alarms_pkey;'
    execute 'ALTER TABLE alarms ADD PRIMARY KEY (uuid);'

    add_foreign_key :alarm_logs, :alarms, column: :alarm_uuid, primary_key: :uuid
  end
end

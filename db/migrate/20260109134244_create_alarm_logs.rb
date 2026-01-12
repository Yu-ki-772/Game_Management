class CreateAlarmLogs < ActiveRecord::Migration[8.1]
  def change
    create_table :alarm_logs do |t|
      t.references :alarm, null: false, foreign_key: true
      t.datetime :unlocked_at, null: false
      t.integer :minutes_to_unlock

      t.timestamps
    end
  end
end

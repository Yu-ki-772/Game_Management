class CreateAlarms < ActiveRecord::Migration[8.1]
  def change
    create_table :alarms do |t|
      t.string :label, default: "アラーム", null: false
      t.datetime :scheduled_at, null: false
      t.boolean :sent, default: false, null: false
      t.references :user, null: false, foreign_key: true
      t.timestamps
    end
  end
end

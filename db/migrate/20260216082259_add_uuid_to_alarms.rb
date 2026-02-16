class AddUuidToAlarms < ActiveRecord::Migration[8.1]
  def change
    add_column :alarms, :uuid, :uuid, default: 'gen_random_uuid()', null: false
    add_index :alarms, :uuid, unique: true
  end
end

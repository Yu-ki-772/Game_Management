class AddStartedAtToAlarms < ActiveRecord::Migration[8.1]
  def change
    add_column :alarms, :started_at, :datetime
  end
end

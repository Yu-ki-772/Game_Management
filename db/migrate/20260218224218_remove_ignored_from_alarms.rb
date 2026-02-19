class RemoveIgnoredFromAlarms < ActiveRecord::Migration[8.1]
  def change
    remove_column :alarms, :ignored, :boolean
  end
end

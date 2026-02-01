class AddUnlockedAndIgnoredToAlarms < ActiveRecord::Migration[8.1]
  def change
    add_column :alarms, :unlocked, :boolean, default: false, null: false

    # ユーザがアラームをストップした時刻が遅かったどうかのフラグ
    add_column :alarms, :ignored, :boolean, default: false, null: false
  end
end

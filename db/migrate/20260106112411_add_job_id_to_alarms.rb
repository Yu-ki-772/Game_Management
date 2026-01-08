class AddJobIdToAlarms < ActiveRecord::Migration[8.1]
  def change
    # アラーム送信ジョブとアラームの状態を紐付けるために使用
    add_column :alarms, :job_id, :string
    add_index :alarms, :job_id
  end
end

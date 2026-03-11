class CreateDiagnosisResults < ActiveRecord::Migration[8.1]
  def change
    create_table :diagnosis_results do |t|
      t.uuid    :user_uuid,         null: false
      t.decimal :control_score,     precision: 3, scale: 1, null: false
      t.decimal :life_score,        precision: 3, scale: 1, null: false
      t.decimal :quality_score,     precision: 3, scale: 1, null: false
      t.decimal :consistency_score, precision: 3, scale: 1, null: false
      t.decimal :total_score,       precision: 4, scale: 1, null: false

      t.timestamps
    end

    add_index :diagnosis_results, :user_uuid
    add_foreign_key :diagnosis_results, :users,
                    column: :user_uuid,
                    primary_key: :uuid
  end
end

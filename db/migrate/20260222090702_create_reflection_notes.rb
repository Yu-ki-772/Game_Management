class CreateReflectionNotes < ActiveRecord::Migration[8.1]
  def change
    create_table :reflection_notes, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.uuid    :user_uuid,        null: false
      t.string  :title
      t.text    :body,             null: false
      t.integer :reflection_type,  null: false, default: 1

      t.timestamps
    end

    add_index :reflection_notes, :user_uuid
    add_foreign_key :reflection_notes, :users, column: :user_uuid, primary_key: :uuid
  end
end

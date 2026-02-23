class CreateReflectionNoteTags < ActiveRecord::Migration[8.1]
  def change
    create_table :reflection_note_tags do |t|
      t.uuid   :reflection_note_id, null: false
      t.bigint :tag_id,             null: false

      t.timestamps
    end

    add_index :reflection_note_tags, :reflection_note_id
    add_index :reflection_note_tags, :tag_id
    add_index :reflection_note_tags, %i[reflection_note_id tag_id], unique: true

    add_foreign_key :reflection_note_tags, :reflection_notes, column: :reflection_note_id, primary_key: :id
    add_foreign_key :reflection_note_tags, :tags, column: :tag_id
  end
end

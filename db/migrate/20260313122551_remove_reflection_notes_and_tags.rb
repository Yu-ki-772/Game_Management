class RemoveReflectionNotesAndTags < ActiveRecord::Migration[8.1]
  def change
    drop_table :reflection_note_tags do |t|
      t.uuid   :reflection_note_id, null: false
      t.bigint :tag_id,             null: false
      t.timestamps
    end

    drop_table :reflection_notes do |t|
      t.uuid    :user_uuid,       null: false
      t.text    :body,            null: false
      t.integer :reflection_type, null: false, default: 1
      t.string  :title
      t.timestamps
    end

    drop_table :tags do |t|
      t.uuid   :user_uuid, null: false
      t.string :name,      null: false
      t.timestamps
    end
  end
end

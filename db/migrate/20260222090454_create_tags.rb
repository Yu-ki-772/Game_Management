class CreateTags < ActiveRecord::Migration[8.1]
  def change
    create_table :tags do |t|
      t.string :name, null: false
      t.uuid   :user_uuid, null: false

      t.timestamps
    end

    add_index :tags, :user_uuid
    add_index :tags, %i[user_uuid name], unique: true
    add_foreign_key :tags, :users, column: :user_uuid, primary_key: :uuid
  end
end

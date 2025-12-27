class CreateMessageTemplates < ActiveRecord::Migration[8.1]
  def change
    create_table :message_templates do |t|
      t.string :reason, null:false
      t.string :template, null:false

      t.timestamps
    end
  end
end

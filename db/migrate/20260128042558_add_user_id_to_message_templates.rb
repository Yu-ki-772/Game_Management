class AddUserIdToMessageTemplates < ActiveRecord::Migration[8.1]
  def change
    add_reference :message_templates, :user, foreign_key: true
  end
end

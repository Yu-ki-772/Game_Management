class AddPwaInstallPromptedToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :pwa_install_prompted, :boolean, null: false, default: false
  end
end

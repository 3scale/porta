class AddAdminBotProtectionToSettings < ActiveRecord::Migration[6.1]
  def up
    add_column :settings, :admin_bot_protection_level, :string
    change_column_default :settings, :admin_bot_protection_level, "none"
  end

  def down
    remove_column :settings, :admin_bot_protection_level
  end
end

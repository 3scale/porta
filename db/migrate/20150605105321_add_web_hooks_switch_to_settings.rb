class AddWebHooksSwitchToSettings < ActiveRecord::Migration

  def self.up
    add_column :settings, :web_hooks_switch, :string, default: 'denied'
    execute %{ UPDATE settings SET web_hooks_switch = 'hidden' }
    change_column_null :settings, :web_hooks_switch, false
  end

  def self.down
    remove_column :settings, :web_hooks_switch
  end

end

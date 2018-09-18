class AddGroupsSwitchToSettings < ActiveRecord::Migration
  def self.up
    add_column :settings, :groups_switch, :string
    execute %{ UPDATE settings SET groups_switch = 'hidden' }
    change_column_null :settings, :groups_switch, false
  end

  def self.down
    remove_column :settings, :groups_switch
  end
end

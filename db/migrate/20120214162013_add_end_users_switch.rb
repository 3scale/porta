class AddEndUsersSwitch < ActiveRecord::Migration
  def self.up
    add_column :settings, :end_users_switch, :string
    execute %{ UPDATE settings SET end_users_switch = 'hidden' }
    change_column_null :settings, :end_users_switch, false
  end

  def self.down
    remove_column :settings, :end_users_switch
  end
end

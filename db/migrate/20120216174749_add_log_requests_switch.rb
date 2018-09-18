class AddLogRequestsSwitch < ActiveRecord::Migration
  def self.up
    add_column :settings, :log_requests_switch, :string
    execute %{ UPDATE settings SET log_requests_switch = 'hidden' }
    change_column_null :settings, :log_requests_switch, false
  end

  def self.down
    remove_column :settings, :log_requests_switch
  end
end

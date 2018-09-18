class AddDefaultLogRequestsSwitch < ActiveRecord::Migration
  def change
    change_column :settings, :log_requests_switch, :string, :default => 'denied'
  end
end

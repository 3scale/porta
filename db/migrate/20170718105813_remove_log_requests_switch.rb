class RemoveLogRequestsSwitch < ActiveRecord::Migration
  def change
    remove_column :settings, :log_requests_switch
  end
end

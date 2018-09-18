class ChangeDefaultValueOfBackendV2InAccounts < ActiveRecord::Migration
  def self.up
    change_column_default :accounts, :backend_v2, 1
  end

  def self.down
    change_column_default :accounts, :backend_v2, 0
  end
end

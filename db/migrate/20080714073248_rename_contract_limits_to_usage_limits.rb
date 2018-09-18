class RenameContractLimitsToUsageLimits < ActiveRecord::Migration
  def self.up
    rename_table :contract_limits, :usage_limits
  end

  def self.down
    rename_table :usage_limits, :contract_limits
  end
end

class RenameContractMetricsToMetrics < ActiveRecord::Migration
  def self.up
    rename_table :contract_metrics, :metrics
  end

  def self.down
    rename_table :metrics, :contract_metrics
  end
end

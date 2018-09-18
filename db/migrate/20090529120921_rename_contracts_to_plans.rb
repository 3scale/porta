class RenameContractsToPlans < ActiveRecord::Migration
  def self.up
    rename_table :contracts, :plans
  end

  def self.down
    rename_table :plans, :contracts
  end
end

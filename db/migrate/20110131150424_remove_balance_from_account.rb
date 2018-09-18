class RemoveBalanceFromAccount < ActiveRecord::Migration
  def self.up
    remove_column :accounts, :buyerbalance
    remove_column :accounts, :providerbalance
  end

  def self.down
  end
end

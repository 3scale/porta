class AddDeltaToAccounts < ActiveRecord::Migration
  def self.up
    add_column :accounts, :delta, :boolean, :null => false, :default => true
  end

  def self.down
    remove_column :accounts, :delta
  end
end

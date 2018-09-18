class AddMasterToAccounts < ActiveRecord::Migration
  def self.up
    add_column :accounts, :master, :boolean
    add_index :accounts, :master, :unique => true
  end

  def self.down
    remove_index :accounts, :column => :master
    remove_column :accounts, :master
  end
end

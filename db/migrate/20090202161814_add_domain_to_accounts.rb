class AddDomainToAccounts < ActiveRecord::Migration
  def self.up
    add_column :accounts, :domain, :string
    add_index :accounts, :domain, :unique => true
  end

  def self.down
    remove_column :accounts, :domain
  end
end

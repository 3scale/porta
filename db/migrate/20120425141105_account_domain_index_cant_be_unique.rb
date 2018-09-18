class AccountDomainIndexCantBeUnique < ActiveRecord::Migration
  def self.up
    remove_index :accounts, :domain
    add_index :accounts, :domain
  end

  def self.down
    remove_index :accounts, :domain
    add_index :accounts, :domain, :unique => true
  end
end

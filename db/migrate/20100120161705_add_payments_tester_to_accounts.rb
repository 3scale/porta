class AddPaymentsTesterToAccounts < ActiveRecord::Migration
  def self.up
    add_column :accounts, :payments_tester, :boolean, :null => false, :default => false
  end

  def self.down
    remove_column :accounts, :payments_tester
  end
end

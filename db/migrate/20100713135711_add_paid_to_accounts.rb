class AddPaidToAccounts < ActiveRecord::Migration
  def self.up
    add_column :accounts, :paid, :boolean, :default => false
  end

  def self.down
    remove_column :accounts, :paid
  end
end

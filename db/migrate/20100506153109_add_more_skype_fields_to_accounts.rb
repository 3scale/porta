class AddMoreSkypeFieldsToAccounts < ActiveRecord::Migration
  def self.up
    add_column :accounts, :org_legaladdress_cont, :string
    add_column :accounts, :city, :string
    add_column :accounts, :state_region, :string
  end

  def self.down
    remove_column :accounts, :org_legaladdress_cont
    remove_column :accounts, :city
    remove_column :accounts, :state_region
  end
end

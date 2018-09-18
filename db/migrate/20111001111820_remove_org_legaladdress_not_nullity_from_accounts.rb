class RemoveOrgLegaladdressNotNullityFromAccounts < ActiveRecord::Migration
  def self.up
    change_column :accounts, "org_legaladdress", :string, :default => "", :null => true
  end

  def self.down
    change_column :accounts, "org_legaladdress", :string, :default => "", :null => false
  end
end

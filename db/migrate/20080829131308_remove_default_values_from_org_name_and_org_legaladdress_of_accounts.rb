class RemoveDefaultValuesFromOrgNameAndOrgLegaladdressOfAccounts < ActiveRecord::Migration
  def self.up
    change_table :accounts do |t|
      t.change :org_name, :string, :null => false, :default => ''
      t.change :org_legaladdress, :string, :null => false, :default => ''
    end
  end

  def self.down
  end
end

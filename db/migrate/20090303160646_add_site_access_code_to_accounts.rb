class AddSiteAccessCodeToAccounts < ActiveRecord::Migration
  def self.up
    add_column :accounts, :site_access_code, :string
  end

  def self.down
    remove_column :accounts, :site_access_code
  end
end

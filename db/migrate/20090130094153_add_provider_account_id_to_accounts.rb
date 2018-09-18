class AddProviderAccountIdToAccounts < ActiveRecord::Migration
  def self.up
    change_table :accounts do |t|
      t.integer :provider_account_id
      t.index  :provider_account_id
    end
  end

  def self.down
    change_table :accounts do |t|
      t.remove :provider_account_id
    end
  end
end

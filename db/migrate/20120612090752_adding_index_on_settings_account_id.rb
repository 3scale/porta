class AddingIndexOnSettingsAccountId < ActiveRecord::Migration
  def self.up
    add_index :settings, :account_id, :unique => true
  end

  def self.down
    remove_index :settings, :account_id
  end
end

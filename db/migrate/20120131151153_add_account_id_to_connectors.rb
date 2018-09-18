class AddAccountIdToConnectors < ActiveRecord::Migration
  def self.up
    add_column :connectors, :account_id, :bigint
    add_index :connectors, :account_id
  end

  def self.down
    remove_column :connectors, :account_id
  end
end

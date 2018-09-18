class RemoveConnectorAccountId < ActiveRecord::Migration
  def self.up
    remove_column :connectors, :account_id
  end

  def self.down
    add_column :connectors, :account_id, :bigint
  end
end

class AddConnectorIndex < ActiveRecord::Migration
  def self.up
    add_index :connectors, :connectable_id
  end

  def self.down
    remove_index :connectors, :connectable_id
  end
end

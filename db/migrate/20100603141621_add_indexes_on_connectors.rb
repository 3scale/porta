class AddIndexesOnConnectors < ActiveRecord::Migration

  def self.up
    add_index :connectors, 'page_id', :name => 'idx_page_id'
    add_index :connectors, 'page_version', :name => 'idx_page_version'
    add_index :connectors, 'container', :name => 'idx_container'
  end

  def self.down
    remove_index :connectors, :name => 'idx_page_id'
    remove_index :connectors, :name => 'idx_page_version'
    remove_index :connectors, :name => 'idx_container'
  end
end

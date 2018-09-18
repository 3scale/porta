class AddIndexesOnPageVersions < ActiveRecord::Migration

  def self.up
    add_index :page_versions, 'page_id', :name => 'idx_page_id'
    add_index :page_versions, 'version', :name => 'idx_version'
  end

  def self.down
    remove_index :page_versions, :name => 'idx_page_id'
    remove_index :page_versions, :name => 'idx_version'
  end
end

class AddIndexesOnHtmlBlocks < ActiveRecord::Migration
  def self.up
    add_index :html_block_versions, 'html_block_id', :name => 'idx_html_block_id'
    add_index :html_block_versions, 'version', :name => 'idx_html_block_version'
  end

  def self.down
    remove_index :html_block_versions, :name => 'idx_html_block_id'
    remove_index :html_block_versions, :name => 'idx_html_block_version'
  end
end

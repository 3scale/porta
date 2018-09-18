class AddMarkupToBcms < ActiveRecord::Migration
  def self.up
    add_column :html_blocks, :markup_type, :string, :default => 'simple'
    add_column :html_blocks, :content_with_markup, :string, :limit => 2147483647
    add_column :html_block_versions, :markup_type, :string, :default => 'simple'
    add_column :html_block_versions, :content_with_markup, :string, :limit => 2147483647
  end

  def self.down
    remove_column :html_blocks, :markup_type
    remove_column :html_blocks, :content_with_markup
    remove_column :html_block_versions, :markup_type
    remove_column :html_block_versions, :content_with_markup
  end
end

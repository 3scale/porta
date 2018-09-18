class AddAccountIdToHtmlBlocks < ActiveRecord::Migration
  def self.up
    add_column :html_blocks, :account_id, :integer
  end

  def self.down
    remove_column :html_blocks, :account_id
  end
end

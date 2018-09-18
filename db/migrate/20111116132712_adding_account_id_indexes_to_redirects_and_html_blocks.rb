class AddingAccountIdIndexesToRedirectsAndHtmlBlocks < ActiveRecord::Migration
  def self.up
    add_index :html_blocks, 'account_id'

    add_column :html_block_versions, :account_id, :integer
    add_index  :html_block_versions, 'account_id'

    add_index :redirects, 'account_id'
  end

  def self.down
    remove_index :html_blocks, 'account_id'

    remove_column :html_block_versions, :account_id

    remove_index :redirects, 'account_id'
  end
end

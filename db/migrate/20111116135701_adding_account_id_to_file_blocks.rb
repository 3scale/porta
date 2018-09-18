class AddingAccountIdToFileBlocks < ActiveRecord::Migration
  def self.up
    add_column :file_blocks, :account_id, :integer
    add_index  :file_blocks, 'account_id'

    add_column :file_block_versions, :account_id, :integer
    add_index  :file_block_versions, 'account_id'
  end

  def self.down
    remove_column :file_blocks, :account_id
    remove_column :file_block_versions, :account_id
  end
end

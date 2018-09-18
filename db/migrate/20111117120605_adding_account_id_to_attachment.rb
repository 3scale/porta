class AddingAccountIdToAttachment < ActiveRecord::Migration
  def self.up
    add_column :attachments, :account_id, :integer
    add_index  :attachments, 'account_id'

    add_column :attachment_versions, :account_id, :integer
    add_index  :attachment_versions, 'account_id'
  end

  def self.down
    remove_column :attachments, :account_id
    remove_column :attachment_versions, :account_id
  end
end

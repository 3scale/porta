class AddAccountIdToTags < ActiveRecord::Migration
  def self.up
    add_column :tags, :account_id, :integer
    add_index  :tags, 'account_id'
  end

  def self.down
    remove_column :tags, :account_id
  end
end

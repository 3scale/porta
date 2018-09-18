class AddAccountIdToGroups < ActiveRecord::Migration
  def self.up
    add_column :groups, :account_id, :integer
    add_index  :groups, 'account_id'
  end

  def self.down
    remove_column :groups, :account_id
  end
end

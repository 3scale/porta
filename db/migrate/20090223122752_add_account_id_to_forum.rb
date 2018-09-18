class AddAccountIdToForum < ActiveRecord::Migration
  def self.up
    add_column :forums, :account_id, :integer
  end

  def self.down
    remove_column :forums, :account_id
  end
end

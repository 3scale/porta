class AddAccountIdToLinks < ActiveRecord::Migration
  def self.up
    add_column :links, :account_id, :integer
  end

  def self.down
    remove_column :links, :account_id
  end
end

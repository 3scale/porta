class AddIndexOnUserAccountId < ActiveRecord::Migration
  def self.up
    add_index :users, 'account_id', :name => 'idx_account_id'
  end

  def self.down
    remove_index :users, :name => 'idx_account_id'
  end
end

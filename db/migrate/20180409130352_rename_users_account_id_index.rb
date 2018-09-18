class RenameUsersAccountIdIndex < ActiveRecord::Migration
  def change
    rename_index :users, 'idx_account_id', 'idx_users_account_id'
  end
end

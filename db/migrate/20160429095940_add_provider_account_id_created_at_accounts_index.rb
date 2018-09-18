class AddProviderAccountIdCreatedAtAccountsIndex < ActiveRecord::Migration
  def change
    add_index :accounts, [:provider_account_id, :created_at]
  end
end

class AddNotNullCreatedAtToAccounts < ActiveRecord::Migration
  def change
    Account.where(created_at: nil).delete_all
    change_column_null(:accounts, :created_at, false)
  end
end

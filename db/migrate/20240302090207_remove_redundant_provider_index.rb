class  RemoveRedundantProviderIndex < ActiveRecord::Migration[6.0]
  disable_ddl_transaction! if System::Database.postgres?

  def up
    remove_index :accounts, column: :provider_account_id if index_exists?(:accounts, :provider_account_id)
    remove_index :invoices, column: :provider_account_id if index_exists?(:invoices, :provider_account_id)
  end
end

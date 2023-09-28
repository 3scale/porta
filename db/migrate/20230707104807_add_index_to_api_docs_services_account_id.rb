class AddIndexToApiDocsServicesAccountId < ActiveRecord::Migration[5.2]
  disable_ddl_transaction! if System::Database.postgres?

  def change
    index_options = System::Database.postgres? ? { algorithm: :concurrently } : {}
    add_index :api_docs_services, :account_id, index_options
  end
end

class AddOwnerToApiDocsServices < ActiveRecord::Migration[5.0]
  disable_ddl_transaction!
  def change
    add_column :api_docs_services, :owner_id, :bigint
    add_column :api_docs_services, :owner_type, :string

    index_options = System::Database.postgres? ? { algorithm: :concurrently } : {}
    add_index :api_docs_services, [:owner_type, :owner_id], index_options
  end
end

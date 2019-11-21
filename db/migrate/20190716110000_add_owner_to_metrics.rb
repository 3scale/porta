class AddOwnerToMetrics < ActiveRecord::Migration
  disable_ddl_transaction!

   def change
    return if ActiveRecord::Base.connection.index_exists?(:metrics, [:owner_type, :owner_id])

    add_column :metrics, :owner_id, :integer, limit: 8
    add_column :metrics, :owner_type, :string

    index_options = System::Database.postgres? ? { algorithm: :concurrently } : {}
    add_index :metrics, [:owner_type, :owner_id], index_options
  end
end

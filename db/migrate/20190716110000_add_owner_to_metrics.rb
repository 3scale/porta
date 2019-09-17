class AddOwnerToMetrics < ActiveRecord::Migration
  disable_ddl_transaction!

   def change
    return if ActiveRecord::SchemaMigration.find_by(version: 20190805135730) # this migration was repositioned back

    add_column :metrics, :owner_id, :integer, limit: 8
    add_column :metrics, :owner_type, :string

    index_options = System::Database.postgres? ? { algorithm: :concurrently } : {}
    add_index :metrics, [:owner_type, :owner_id], index_options
    add_index :metrics, [:owner_type, :owner_id, :system_name], index_options.merge(unique: true)
  end
end

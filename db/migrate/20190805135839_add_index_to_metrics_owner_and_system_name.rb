class AddIndexToMetricsOwnerAndSystemName < ActiveRecord::Migration
  disable_ddl_transaction!

   def change
    return if ActiveRecord::Base.connection.index_exists?(:metrics, [:owner_type, :owner_id, :system_name])

    index_options = { unique: true }
    index_options[:algorithm] = :concurrently if System::Database.postgres?
    add_index :metrics, [:owner_type, :owner_id, :system_name], index_options
  end
end

class RemoveUniquenessFromIndexOnMetricsServiceSystemName < ActiveRecord::Migration
  disable_ddl_transaction!

  def self.up
    remove_index :metrics, [:service_id, :system_name]

    index_options = System::Database.postgres? ? { algorithm: :concurrently } : {}
    add_index :metrics, [:service_id, :system_name], index_options.merge(unique: false)
  end

  def self.down
    # This is not reversible, but it does not matter.
  end
end

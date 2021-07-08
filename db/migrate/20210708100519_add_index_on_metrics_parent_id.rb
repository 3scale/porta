class AddIndexOnMetricsParentId < ActiveRecord::Migration[5.0]
  disable_ddl_transaction! if System::Database.postgres?

  def change
    index_options = System::Database.postgres? ? { algorithm: :concurrently } : {}
    add_index :metrics, :parent_id, index_options
  end
end

class AddIndexToAuditsAuditableIdAuditableTypeVersion < ActiveRecord::Migration
  disable_ddl_transaction! if System::Database.postgres?

  def change
    index_options = System::Database.postgres? ? { algorithm: :concurrently } : {}
    add_index :audits, [:auditable_id, :auditable_type, :version], index_options
  end
end

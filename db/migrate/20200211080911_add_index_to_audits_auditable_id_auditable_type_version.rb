class AddIndexToAuditsAuditableIdAuditableTypeVersion < ActiveRecord::Migration
  def change
    add_index :audits, [:auditable_id, :auditable_type, :version]
  end
end

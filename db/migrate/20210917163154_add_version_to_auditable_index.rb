# frozen_string_literal: true

class AddVersionToAuditableIndex < ActiveRecord::Migration[5.0]
  disable_ddl_transaction! if System::Database.postgres?

  def self.up
    if index_exists?(:audits, [:auditable_type, :auditable_id], name: index_name)
      remove_index :audits, name: index_name
      add_index :audits, [:auditable_type, :auditable_id, :version], name: index_name, **index_options
    end
  end

  def self.down
    if index_exists?(:audits, [:auditable_type, :auditable_id, :version], name: index_name)
      remove_index :audits, name: index_name
      add_index :audits, [:auditable_type, :auditable_id], name: index_name, **index_options
    end
  end

  private

  def index_name
    'auditable_index'
  end

  def index_options
    System::Database.postgres? ? { algorithm: :concurrently } : {}
  end
end

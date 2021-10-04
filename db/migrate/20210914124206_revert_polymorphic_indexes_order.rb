# frozen_string_literal: true

class RevertPolymorphicIndexesOrder < ActiveRecord::Migration[5.0]
  disable_ddl_transaction! if System::Database.postgres?

  def self.up
    fix_index_order_for [:associated_id, :associated_type], 'associated_index'
    fix_index_order_for [:auditable_id, :auditable_type], 'auditable_index'
  end

  def self.down
    fix_index_order_for [:associated_type, :associated_id], 'associated_index'
    fix_index_order_for [:auditable_type, :auditable_id], 'auditable_index'
  end

  private

  def fix_index_order_for(columns, index_name)
    if index_exists? :audits, columns, name: index_name
      remove_index :audits, name: index_name

      index_options = System::Database.postgres? ? { algorithm: :concurrently } : {}
      add_index :audits, columns.reverse, name: index_name, **index_options
    end
  end
end

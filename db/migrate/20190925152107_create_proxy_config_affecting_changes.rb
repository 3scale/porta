# frozen_string_literal: true

class CreateProxyConfigAffectingChanges < ActiveRecord::Migration
  disable_ddl_transaction! if System::Database.postgres?

  def change
    create_table :proxy_config_affecting_changes do |t|
      t.references :proxy, null: false
      t.timestamps null: false
    end

    index_options = System::Database.postgres? ? { algorithm: :concurrently } : {}
    add_index :proxy_config_affecting_changes, :proxy_id, index_options.merge(unique: true)
  end
end

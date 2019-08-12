class AddOwnerToProxyRules < ActiveRecord::Migration
  disable_ddl_transaction!

  def change
    add_column :proxy_rules, :owner_id, :integer, limit: 8
    add_column :proxy_rules, :owner_type, :string

    index_options = System::Database.postgres? ? { algorithm: :concurrently } : {}
    add_index :proxy_rules, [:owner_type, :owner_id], index_options
  end
end

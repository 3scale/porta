class AddIndexOnProxyConfigsEnvs < ActiveRecord::Migration
  disable_ddl_transaction! if System::Database.postgres?

  def change
    index_options = System::Database.postgres? ? { algorithm: :concurrently } : {}
    add_index :proxy_configs, %i[proxy_id environment version], index_options
  end
end

class ExtendPolicyChainMySql < ActiveRecord::Migration[5.2]
  # Oracle and PostgreSQL do not need this as their `policies_config` has unlimited size
  def up
    change_column :proxies, :policies_config, :mediumtext if System::Database.mysql?
  end
end

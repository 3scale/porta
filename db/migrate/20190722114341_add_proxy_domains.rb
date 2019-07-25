class AddProxyDomains < ActiveRecord::Migration
  disable_ddl_transaction! if System::Database.postgres?

  def change
    add_column :proxies, :staging_domain, :string
    add_column :proxies, :production_domain, :string

    index_options = System::Database.postgres? ? { algorithm: :concurrently } : {}
    add_index :proxies, [ :staging_domain, :production_domain ], index_options

    reversible do |dir|
      dir.up do
        Proxy.reset_column_information

        Proxy.select(:id, :sandbox_endpoint, :endpoint).find_each do |proxy|
          proxy.update_columns proxy.update_domains
        end
      end
    end
  end
end

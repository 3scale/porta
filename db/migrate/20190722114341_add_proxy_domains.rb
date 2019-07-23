class AddProxyDomains < ActiveRecord::Migration
  def change
    add_column :proxies, :staging_domain, :string
    add_column :proxies, :production_domain, :string

    add_index :proxies, [ :staging_domain, :production_domain ]

    reversible do |dir|
      dir.up do
        Proxy.reset_column_information

        Proxy.select(:id, :sandbox_endpoint, :endpoint).find_in_batches(batch_size: 1000) do |batch|
          batch.each do |proxy|
            proxy.update_columns proxy.update_domains
          end
        end
      end
    end
  end
end

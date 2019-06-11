class AddProxiesOIDCIssuerType < ActiveRecord::Migration
  def change
    add_column :proxies, :oidc_issuer_type, :string, default: nil

    reversible do |dir|
      dir.up do
        Proxy.where.not(oidc_issuer_endpoint: nil).select(:id).find_in_batches(batch_size: 10_000) do |batch|
          Proxy.where(id: batch).update_all(oidc_issuer_type: 'keycloak')
        end

        change_column_default :proxies, :oidc_issuer_type, 'keycloak'
      end
    end
  end
end

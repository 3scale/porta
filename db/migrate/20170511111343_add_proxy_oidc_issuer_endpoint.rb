class AddProxyOIDCIssuerEndpoint < ActiveRecord::Migration
  def change
    add_column :proxies, :oidc_issuer_endpoint, :string
  end
end

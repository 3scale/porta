class AddTenantIdToAuthenticationProviders < ActiveRecord::Migration
  def change
    add_column :authentication_providers, :tenant_id, :bigint
  end
end

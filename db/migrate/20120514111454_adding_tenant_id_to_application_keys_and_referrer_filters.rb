class AddingTenantIdToApplicationKeysAndReferrerFilters < ActiveRecord::Migration
  def self.up
    add_column :application_keys, :tenant_id, :integer, :limit => 8
    add_column :referrer_filters, :tenant_id, :integer, :limit => 8
  end

  def self.down
    drop_column :application_keys, :tenant_id
    drop_column :application_keys, :tenant_id
  end
end

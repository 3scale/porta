class CreateProxies < ActiveRecord::Migration
  def self.up
    create_table :proxies do |t|
      t.integer  :tenant_id, :limit => 8
      t.integer  :service_id, :limit => 8

      t.boolean  :enabled,                               :default => false
      t.string   :endpoint
      t.datetime :deployed_at
      t.string   :api_backend
      t.string   :auth_app_key,                          :default => "app_key"
      t.string   :auth_app_id,                           :default => "app_id"
      t.string   :auth_user_key,                         :default => "user_key"
      t.string   :credentials_location,                  :default => "query",    :null => false
      t.string   :error_over_limit, :default => 'Limits exceeded'
      t.string   :error_auth_failed, :default => 'Authentication failed'
      t.string   :error_auth_missing, :default => 'Authentication parameters missing'

      t.timestamps
    end

    remove_column :services, "proxy_endpoint"
    remove_column :services, "proxy_enabled"
    remove_column :services, "proxy_deployed_at"
    remove_column :services, "proxy_api_backend"
    remove_column :services, "proxy_auth_app_key"
    remove_column :services, "proxy_auth_app_id"
    remove_column :services, "proxy_auth_user_key"
    remove_column :services, "proxy_credentials_location"
  end

  def self.down
    drop_table :proxies
  end
end

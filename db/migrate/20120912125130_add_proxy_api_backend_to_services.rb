class AddProxyApiBackendToServices < ActiveRecord::Migration
  def self.up
    add_column :services, :proxy_api_backend, :string
    add_column :services, :proxy_auth_app_key, :string, :default => 'app_key'
    add_column :services, :proxy_auth_app_id, :string, :default => 'app_id'
    add_column :services, :proxy_auth_user_key, :string, :default => 'user_key'
    add_column :services, :proxy_auth_oauth_app_key, :string
    add_column :services, :proxy_auth_oauth_app_id, :string
  end

  def self.down
    remove_column :services, :proxy_api_backend
    remove_column :services, :proxy_auth_app_key
    remove_column :services, :proxy_auth_app_id
    remove_column :services, :proxy_auth_user_key
    remove_column :services, :proxy_auth_oauth_app_key
    remove_column :services, :proxy_auth_oauth_app_id
  end

end

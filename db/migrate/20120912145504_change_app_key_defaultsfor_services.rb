class ChangeAppKeyDefaultsforServices < ActiveRecord::Migration
  def self.up
    change_column :services, :proxy_auth_app_id, :string, :default => 'app_id'
    change_column :services, :proxy_auth_app_key, :string, :default => 'app_key'
    change_column :services, :proxy_auth_user_key, :string, :default => 'user_key'
    change_column :services, :proxy_auth_oauth_app_key, :string, :default => 'user_key'
    change_column :services, :proxy_auth_oauth_app_id, :string, :default => 'user_key'
  end

  def self.down
  end
end

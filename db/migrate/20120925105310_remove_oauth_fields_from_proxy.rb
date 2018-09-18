class RemoveOauthFieldsFromProxy < ActiveRecord::Migration
  def self.up
    remove_column :services, :proxy_auth_oauth_app_key
    remove_column :services, :proxy_auth_oauth_app_id
  end

  def self.down
    add_column :services, :proxy_auth_oauth_app_key, :string
    add_column :services, :proxy_auth_oauth_app_id, :string
  end
end

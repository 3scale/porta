class AddProxyCredentialsLocationToService < ActiveRecord::Migration
  def self.up
    add_column :services, :proxy_credentials_location, :string, :null => false, :default => 'query'
  end

  def self.down
    remove_column :services, :proxy_credentials_location
  end
end

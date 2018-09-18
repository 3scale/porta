class AddProxyStuffToService < ActiveRecord::Migration
  def self.up
    add_column :services, :proxy_endpoint, :string
    add_column :services, :proxy_enabled, :string
    add_column :services, :proxy_deployed_at, :datetime
  end

  def self.down
    remove_column :services, :proxy_endpoint
    remove_column :services, :proxy_enabled
    remove_column :services, :proxy_deployed_at
  end
end

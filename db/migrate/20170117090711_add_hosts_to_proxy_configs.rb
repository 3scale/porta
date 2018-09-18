class AddHostsToProxyConfigs < ActiveRecord::Migration
  def change
    add_column :proxy_configs, :hosts, :string, limit: 8192
  end
end

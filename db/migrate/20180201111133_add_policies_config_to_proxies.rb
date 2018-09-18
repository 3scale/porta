class AddPoliciesConfigToProxies < ActiveRecord::Migration
  def change
    add_column :proxies, :policies_config, :text
  end
end

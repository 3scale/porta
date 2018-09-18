class AddProxyIdIndexToProxyRules < ActiveRecord::Migration
  def change
    add_index :proxy_rules, :proxy_id
  end
end

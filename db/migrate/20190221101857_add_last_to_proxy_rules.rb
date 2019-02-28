class AddLastToProxyRules < ActiveRecord::Migration
  def change
    add_column :proxy_rules, :last, :boolean, default: false
  end
end

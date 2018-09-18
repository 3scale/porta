class AddRedirectUrlToProxyRules < ActiveRecord::Migration
  def change
    add_column :proxy_rules, :redirect_url, :string
  end
end

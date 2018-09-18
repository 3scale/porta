class ChangeRedirectUrlForProxyRuleToText < ActiveRecord::Migration
  def change
    change_column :proxy_rules, :redirect_url, :text
  end
end

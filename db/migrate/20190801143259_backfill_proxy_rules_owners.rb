require 'progress_counter'

class BackfillProxyRulesOwners < ActiveRecord::Migration
  def up
    say_with_time 'Updating proxy rules owners...' do
      ProxyRule.reset_column_information
      progress = ProgressCounter.new(ProxyRule.count)
      ProxyRule.find_each do |proxy_rule|
        proxy_rule.update_columns(owner_id: proxy_rule.proxy_id, owner_type: 'Proxy') unless proxy_rule.owner_type?
        progress.call
      end
    end
  end
end

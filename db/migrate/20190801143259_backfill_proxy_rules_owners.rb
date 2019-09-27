require 'progress_counter'

class BackfillProxyRulesOwners < ActiveRecord::Migration
  def up
    return puts "Nothing to do, this migration should not be executed" # Moved to lib/tasks/proxy.rake:update_proxy_rule_owners

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

# frozen_string_literal: true

require 'progress_counter'

class UpdateProxyRuleOwners < ActiveRecord::DataMigration
  def up
    progress = ProgressCounter.new(ProxyRule.count)
    ProxyRule.find_each do |proxy_rule|
      proxy_rule.update_columns(owner_id: proxy_rule.proxy_id, owner_type: 'Proxy') unless proxy_rule.owner_type?
      progress.call
    end
  end
end

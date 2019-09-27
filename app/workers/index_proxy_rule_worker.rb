# frozen_string_literal: true

class IndexProxyRuleWorker < ApplicationJob
  def perform(proxy_rule_id)
    proxy_rule = ProxyRule.find(proxy_rule_id)
    ThinkingSphinx::RealTime::Callbacks::RealTimeCallbacks.new(
      :proxy_rule
    ).after_save(proxy_rule)
  end
end

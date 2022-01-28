# frozen_string_literal: true

# TODO: remove this class after one version as we don't use it anymore
class IndexProxyRuleWorker < ApplicationJob
  # TODO: Rails 5.1 -> discard_on ActiveRecord::RecordNotFound
  rescue_from(ActiveRecord::RecordNotFound) do |exception|
    Rails.logger.info exception.message
  end

  def perform(proxy_rule_id)
    proxy_rule = ProxyRule.find(proxy_rule_id)
    ThinkingSphinx::RealTime.callback_for(
      "proxy_rule"
    ).after_commit(proxy_rule)
  end
end

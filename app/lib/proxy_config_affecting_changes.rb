# frozen_string_literal: true

module ProxyConfigAffectingChanges
  module ProxyRuleExtension
    extend ActiveSupport::Concern

    included do
      include ProxyConfigAffectingChanges

      after_commit :issue_proxy_affecting_change_events

      def issue_proxy_affecting_change_events
        case owner
        when Proxy
          issue_proxy_affecting_change_event(owner)
        when BackendApi
          owner.proxies.each(&method(:issue_proxy_affecting_change_event))
        end
      end
    end
  end

  module ProxyExtension
    extend ActiveSupport::Concern

    PROXY_CONFIG_AFFECTING_ATTRIBUTES = %w[policies_config].freeze # TODO: add more attributes here

    included do
      include ProxyConfigAffectingChanges

      after_commit :issue_proxy_affecting_change_events, on: :update

      def issue_proxy_affecting_change_events
        changes_attributes = previous_changes.keys
        return if changes_attributes.include?('created_at') || (changes_attributes & PROXY_CONFIG_AFFECTING_ATTRIBUTES).empty?
        issue_proxy_affecting_change_event(self)
      end
    end
  end

  def issue_proxy_affecting_change_event(proxy)
    ProxyConfigs::AffectingObjectChangedEvent.create_and_publish!(proxy, self)
  end
end

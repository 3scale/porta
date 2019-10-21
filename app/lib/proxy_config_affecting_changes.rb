# frozen_string_literal: true

module ProxyConfigAffectingChanges
  module ProxyRuleExtension
    extend ActiveSupport::Concern

    included do
      include ProxyConfigAffectingChanges

      after_commit :issue_proxy_affecting_change_events

      def issue_proxy_affecting_change_events
        return unless owner

        case owner
        when Proxy
          issue_proxy_affecting_change_event(owner)
        when BackendApi
          owner.proxies.find_each(&method(:issue_proxy_affecting_change_event))
        end
      end
    end
  end

  module ProxyExtension
    extend ActiveSupport::Concern

    included do
      has_one :proxy_config_affecting_change, dependent: :delete
      private :proxy_config_affecting_change

      include ProxyConfigAffectingChanges

      after_commit :issue_proxy_affecting_change_events, on: :update

      def issue_proxy_affecting_change_events
        return if previously_changed?(:created_at) || (previous_changes.keys - %w[updated_at lock_version]).empty?

        issue_proxy_affecting_change_event(self)
      end

      def find_or_create_proxy_config_affecting_change
        proxy_config_affecting_change || create_proxy_config_affecting_change
      end
      alias affecting_change_history find_or_create_proxy_config_affecting_change
      private :find_or_create_proxy_config_affecting_change

      def pending_affecting_changes?
        return unless apicast_configuration_driven?
        config = proxy_configs.sandbox.newest_first.first
        return false unless config
        config.created_at < affecting_change_history.updated_at
      end

      private

      def create_proxy_config_affecting_change(*)
        super
      rescue ActiveRecord::RecordNotUnique
        reload.send(:proxy_config_affecting_change)
      end
    end
  end

  module BackendApiConfigExtension
    extend ActiveSupport::Concern

    included do
      include ProxyConfigAffectingChanges

      after_commit :issue_proxy_affecting_change_events

      def issue_proxy_affecting_change_events
        return unless service

        issue_proxy_affecting_change_event(service.proxy)
      end
    end
  end

  module BackendApiExtension
    extend ActiveSupport::Concern

    included do
      include ProxyConfigAffectingChanges

      after_commit :issue_proxy_affecting_change_events, on: :update

      def issue_proxy_affecting_change_events
        return unless previously_changed?(:private_endpoint)
        proxies.find_each(&method(:issue_proxy_affecting_change_event))
      end
    end
  end

  def issue_proxy_affecting_change_event(proxy)
    ProxyConfigs::AffectingObjectChangedEvent.create_and_publish!(proxy, self)
  end
end

# frozen_string_literal: true

class PublishZyncEventSubscriber
  DEFAULT_PUBLISHER = ->(*args) { Rails.application.config.event_store.publish_event(*args) }

  def initialize(publisher = DEFAULT_PUBLISHER)
    @publisher = publisher || DEFAULT_PUBLISHER
    freeze
  end

  attr_reader :publisher

  delegate :domain_event_in_saas?, :build_zync_event, to: :class

  class << self
    def domain_event_in_saas?(event)
      ThreeScale.saas? && (event.is_a?(Domains::ProxyDomainsChangedEvent) || event.is_a?(Domains::ProviderDomainsChangedEvent))
    end

    def build_zync_event(event)
      case event
      when ApplicationRelatedEvent
        zync_metadata = event.metadata.fetch(:zync, {})
        zync_metadata[:oidc_auth_enabled] || sync_non_oidc_apps ? ZyncEvent.create(event, event.application) : nil
      when OIDC::ProxyChangedEvent, Domains::ProxyDomainsChangedEvent
        ZyncEvent.create(event, event.proxy)
      when OIDC::ServiceChangedEvent
        ZyncEvent.create(event, event.service)
      when Domains::ProviderDomainsChangedEvent
        ZyncEvent.create(event, event.provider)
      else raise "Unknown event type #{event.class}"
      end
    end

    private

    # The default is 'true', if the configuration is missing
    def sync_non_oidc_apps
      !Rails.configuration.zync.skip_non_oidc_applications
    end
  end

  # @param [ZyncEvent] event
  def call(event)
    # skip domain-related events in SaaS
    return if domain_event_in_saas? event

    zync_event = build_zync_event event
    publisher.call(zync_event, 'zync') if zync_event
  end

end

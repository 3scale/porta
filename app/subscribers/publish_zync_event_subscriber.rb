# frozen_string_literal: true

class PublishZyncEventSubscriber
  DEFAULT_PUBLISHER = ->(*args) { Rails.application.config.event_store.publish_event(*args) }

  def initialize(publisher = DEFAULT_PUBLISHER)
    @publisher = publisher || DEFAULT_PUBLISHER
    freeze
  end

  attr_reader :publisher

  # @param [ZyncEvent] event
  def call(event)
    unless ThreeScale.config.onpremises
      case event
      when Domains::ProxyDomainsChangedEvent, Domains::ProviderDomainsChangedEvent
        return
      end
    end

    zync_event = case event
           when ApplicationRelatedEvent
             metadata = event.metadata.fetch(:zync, {})
             # only publish events to Zync for applications using OIDC authentication
             ZyncEvent.create(event, event.application) if metadata[:oidc_auth_enabled]
           when OIDC::ProxyChangedEvent, Domains::ProxyDomainsChangedEvent then ZyncEvent.create(event, event.proxy)
           when OIDC::ServiceChangedEvent then ZyncEvent.create(event, event.service)
           when Domains::ProviderDomainsChangedEvent then ZyncEvent.create(event, event.provider)
           else raise "Unknown event type #{event.class}"
           end

    publisher.call(zync_event, 'zync') if zync_event
  end
end

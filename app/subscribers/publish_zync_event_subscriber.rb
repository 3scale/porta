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
    zync = case event
           # When the app is deleted the event caries all the needed information
           when Cinstances::CinstanceCancellationEvent then ZyncEvent.create(event)
           when ApplicationRelatedEvent then ZyncEvent.create(event, event.application)
           when OIDC::ProxyChangedEvent then ZyncEvent.create(event, event.proxy)
           when OIDC::ServiceChangedEvent then ZyncEvent.create(event, event.service)
           else raise "Unknown event type #{event.class}"
           end

    publisher.call(zync, 'zync')
  end
end

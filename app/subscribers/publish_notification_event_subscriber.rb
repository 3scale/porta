class PublishNotificationEventSubscriber

  attr_reader :system_name

  DEFAULT_PUBLISHER = ->(*args) { Rails.application.config.event_store.publish_event(*args) }

  def initialize(system_name, publisher = DEFAULT_PUBLISHER)
    @system_name = system_name.freeze
    @publisher = publisher
  end

  def call(event)
    notification_event = NotificationEvent.create(system_name, event)

    publish_event(notification_event, event.event_id) if notification_enabled?(event)

    notification_event
  end

  protected

  def notification_enabled?(event)
    NotificationCenter.new(event).enabled?
  end

  def publish_event(*args)
    publisher.call(*args)
  end

  attr_reader :publisher
end

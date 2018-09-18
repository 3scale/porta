class ServiceObserver < ActiveRecord::Observer
  observe :service

  def after_create(service)
    event = Services::ServiceCreatedEvent.create(service, User.current)

    Rails.application.config.event_store.publish_event(event)
  end

  def after_destroy(service)
    Services::ServiceDeletedEvent.create_and_publish!(service)
  end
end

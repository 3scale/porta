class NotificationDeliveryService
  attr_reader :system_name, :event_entity, :user

  class_attribute :mailer, instance_writer: false
  self.mailer = NotificationMailer

  class NotificationDeliveryError < StandardError
    include Bugsnag::MetaData
  end

  class MissingEntityError < NotificationDeliveryError
    def initialize(notification)
      self.bugsnag_meta_data = {
        notification: {
          id: notification.id,
          event_id: notification.event_id,
          user_id: notification.user_id,
          system_name: notification.system_name
        }
      }

      super "Notification #{notification.id} could not build Event #{notification.event_id}"
    end
  end

  class InvalidEventError < NotificationDeliveryError
    def initialize(event)
      self.bugsnag_meta_data = {
        event: {
          event_id: id = event.event_id,
          data:     event.data,
          name:     name = event.class.name
        }
      }

      super "#{name} #{id} is invalid"
    end
  end

  def self.call(notification)
    new(notification).call
  end

  def initialize(notification)
    @notification = notification
    @system_name  = notification.system_name
    @event_entity = notification.parent_event
    @user         = notification.user
  end

  # @return [Mail::Message]
  # @raise [MissingEntityError] when +event_entity+ is missing
  # @raise [InvalidEventError] when +event_entity+ is invalid
  def email_notification
    raise MissingEntityError, notification unless event_entity
    raise InvalidEventError, event_entity if invalid_event?

    mailer.public_send(system_name, event_entity, user)
  end

  def call
    email_notification.try!(:deliver)
  end

  protected

  attr_reader :notification

  private

  def invalid_event?
    event_entity.data.any? { |_key, value| value.blank? }
  end
end

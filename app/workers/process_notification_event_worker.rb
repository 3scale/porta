class ProcessNotificationEventWorker
  include Sidekiq::Job

  def self.enqueue(event)
    batch = Sidekiq::Batch.new
    batch.description = "Processing #{event.class} (id: #{event.event_id})"

    batch.jobs do
      perform_async(event.event_id)
    end
  end

  def perform(event_id)
    event = EventStore::Repository.find_event(event_id)

    create_notifications(event)
  end

  class UserNotificationWorker
    include Sidekiq::Job

    def perform(user_id, event_id, system_name)
      user = User.find(user_id)

      notification = user.notifications.build(event_id: event_id, system_name: system_name)
      notification.deliver! if notification.should_deliver?
    rescue ::NotificationDeliveryService::NotificationDeliveryError => error
      ::System::ErrorReporting.report_error(error)
    rescue ::NotificationDeliveryService::InvalidEventError,
           ::ActiveJob::DeserializationError => e
      ::Rails.logger.error e.message
    end
  end

  # @param [NotificationEvent] event
  # @return [Account]
  def create_notifications(event)
    provider = Provider.find(event.provider_id)
    return if provider.suspended_or_scheduled_for_deletion?

    buyer = provider.buyers.find_by(id: event.try(:account_id))
    return if buyer&.should_be_deleted?

    parallelize do
      provider.users.active.but_impersonation_admin.find_each do |user|
        UserNotificationWorker.perform_async(user.id, event.event_id, event.system_name)
      end
    end

    provider
  rescue ActiveRecord::RecordNotFound => e
    ::Rails.logger.error e.message
    false
  end

  def parallelize
    if batch
      batch.jobs { yield }
    else
      yield
    end
  end
end

class ProcessNotificationEventWorker
  include Sidekiq::Worker

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
    include Sidekiq::Worker

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

    if provider.suspended? || provider.scheduled_for_deletion?
      Rails.logger.info "[Notification] skipping notifications for event #{event.event_id} of #{provider.state} account #{event.provider_id}"
      return
    end

    parallelize do
      provider.users.but_impersonation_admin.find_each do |user|
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

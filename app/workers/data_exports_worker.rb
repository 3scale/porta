require 'zip'
require_dependency 'csv'

class DataExportsWorker
  include Sidekiq::Worker
  sidekiq_options queue: :priority

  def perform(provider_id, recipient_id, type, period)
    provider  = Account.providers_with_master.find(provider_id)
    recipient = User.find(recipient_id)

    if provider.provider_can_use?(:new_notification_system)
      publish_event!(provider, recipient, type, period)
    else
      email(provider, recipient, type, period).deliver_now
    end
  end

  private

  def publish_event!(provider, recipient, type, period)
    event = Reports::CsvDataExportEvent.create(provider, recipient, type, period)

    Rails.application.config.event_store.publish_event(event)
  end

  def email(provider, recipient, type, period)
    export_service = Reports::DataExportService.new(provider, type, period)

    DataExportMailer.export_data(recipient, type, export_service.files)
  end
end

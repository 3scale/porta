# frozen_string_literal: true

require 'zip'

class DataExportsWorker
  include Sidekiq::Job
  sidekiq_options queue: :priority

  def perform(provider_id, recipient_id, type, period)
    provider  = Account.providers_with_master.find(provider_id)
    recipient = User.find(recipient_id)

    publish_event!(provider, recipient, type, period)
  end

  private

  def publish_event!(provider, recipient, type, period)
    event = Reports::CsvDataExportEvent.create(provider, recipient, type, period)

    Rails.application.config.event_store.publish_event(event)
  end
end

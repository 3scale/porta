# frozen_string_literal: true

class BackendDeleteApplicationWorker < ApplicationJob
  queue_as :low

  def perform(event_id)
    event = EventStore::Repository.find_event!(event_id)

    DeletedObject.application_keys.where(owner_type: Contract, owner_id: event.application.id).order(:id).find_each do |deleted_object|
      ThreeScale::Core::ApplicationKey.delete(event.service_id.to_s, event.application_id, deleted_object.metadata[:value])
    end

    DeletedObject.referrer_filters.where(owner_type: Contract, owner_id: event.application.id).order(:id).find_each do |deleted_object|
      ThreeScale::Core::ApplicationReferrerFilter.delete(event.service_id.to_s, event.application_id, deleted_object.metadata[:value])
    end

    ThreeScale::Core::Application.delete(event.service_id.to_s, event.application_id)
  rescue ActiveRecord::RecordNotFound => exception
    System::ErrorReporting.report_error(exception, parameters: {event_id: event_id})
  end
end

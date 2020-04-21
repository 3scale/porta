# frozen_string_literal: true

class BackendDeleteApplicationWorker < ApplicationJob

  queue_as :low

  def self.enqueue(event)
    perform_later(event.event_id)
  end

  def perform(event_id)
    event = EventStore::Repository.find_event!(event_id)

    @application = build_application(event)

    [ApplicationKey, ReferrerFilter].each(&method(:delete_backend_associations))

    delete_backend_application
  rescue ActiveRecord::RecordNotFound => exception
    System::ErrorReporting.report_error(exception, parameters: {event_id: event_id})
  end

  private

  attr_reader :application

  def build_application(event)
    app_attrs = {id: event.application.id, user_key: event.user_key, application_id: event.application_id}
    Cinstance.new(app_attrs, without_protection: true).tap do |app|
      app.service = Service.new({id: event.service_id}, without_protection: true)
    end
  end

  def build_association_object(deleted_object)
    deleted_object.object_instance { |object| object.application = application }
  end

  def delete_backend_associations(klass)
    DeletedObject.public_send(klass.to_s.underscore.pluralize).order(:id).find_each do |deleted_object|
      build_association_object(deleted_object).destroy_backend_value
    end
  end

  def delete_backend_application
    application.delete_backend_user_key_to_application_id_mapping
    application.delete_backend_application
  end
end

# frozen_string_literal: true

module ApplicationAssociationBackendService
  def delete_all(application_id:, service_backend_id:, application_backend_id:)
    DeletedObject.public_send(reflection_name).where(owner_type: Contract.name, owner_id: application_id).order(id: :asc).find_each do |deleted_object|
      delete(service_backend_id: service_backend_id, application_backend_id: application_backend_id, value: deleted_object.metadata[:value])
    end
  end

  def delete(service_backend_id:, application_backend_id:, value:)
    pisoni_class.delete(service_backend_id, application_backend_id, value)
  end

  def reflection_name
    raise NoMethodError, __method__
  end

  def pisoni_class
    raise NoMethodError, __method__
  end
end

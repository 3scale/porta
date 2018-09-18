# frozen_string_literal: true

class ServiceUpdateBackendService
  def initialize(service)
    @service = service
  end

  def update_state!(state_action)
    service_backend = load_service!
    service_backend.public_send(state_action)
    service_backend.save!
  end

  private

  attr_reader :service

  def load_service
    ThreeScale::Core::Service.load_by_id(service.id)
  end

  def load_service!
    load_service or raise Backend::ServiceNotFound
  end
end

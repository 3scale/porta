# frozen_string_literal: true

class ServiceCreationService
  def initialize(provider_account, service_attributes = {})
    @provider_account = provider_account
    @service_attributes = service_attributes
  end

  attr_reader :provider_account, :service_attributes, :success, :service

  def self.call(*args)
    object = new(*args)
    object.call
    object
  end

  def call
    @service = discover? ? create_service_async : create_service
  end

  def create_service
    service = build_service service_attributes.slice(:name, :system_name, :description)
    @success = service.save
    service
  end

  def create_service_async
    ServiceDiscovery::ImportClusterServiceDefinitionsWorker.perform_async(provider_account.id, *service_attributes.values_at(:namespace, :name))
    @success = true
    build_service service_attributes.slice(:name)
  end

  def build_service(attributes = {})
    provider_account.accessible_services.build(attributes.presence || service_attributes)
  end

  def discover?
    service_attributes[:source] == 'discover'
  end

  def success?
    !!success
  end
end

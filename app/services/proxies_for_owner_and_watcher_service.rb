# frozen_string_literal: true

class ProxiesForOwnerAndWatcherService
  def initialize(owner:, watcher: nil)
    @watcher = watcher
    @owner = owner
  end

  def call
    Proxy.where(service_id: service_ids)
  end

  def self.call(**args)
    new(**args).call
  end

  private

  attr_reader :watcher, :owner

  def service_ids
    accessible_services_ids & member_permission_service_ids
  end

  def accessible_services_ids
    []
  end

  def member_permission_service_ids
    ids = watcher.try(:forbidden_some_services?) ? watcher.member_permission_service_ids : nil
    ids || accessible_services_ids
  end
end

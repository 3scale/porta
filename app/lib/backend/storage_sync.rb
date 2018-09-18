# frozen_string_literal: true

class Backend::StorageSync
  def initialize(provider)
    @provider = provider
  end

  def sync_provider
    currently_scheduled_for_deletion = provider.scheduled_for_deletion?
    backend_state_action = currently_scheduled_for_deletion ? :deactivate : :activate
    update_backend backend_state_action
    reenqueue if state_changed_during_update?(currently_scheduled_for_deletion)
  end

  private

  attr_reader :provider

  def update_backend(state_action)
    provider.services.select(:id).find_each do |service|
      ServiceUpdateBackendService.new(service).update_state!(state_action)
    end
  end

  def state_changed_during_update?(previously_scheduled_for_deletion)
    previously_scheduled_for_deletion != provider.reload.scheduled_for_deletion?
  end

  def reenqueue
    BackendProviderSyncWorker.enqueue(provider.id)
  end
end

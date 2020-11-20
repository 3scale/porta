# frozen_string_literal: true

class ProxiesForProviderOwnerAndWatcherService < ProxiesForOwnerAndWatcherService
  private

  def accessible_services_ids
    owner.accessible_services.pluck(:id)
  end
end

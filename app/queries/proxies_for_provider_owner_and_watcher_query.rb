# frozen_string_literal: true

class ProxiesForProviderOwnerAndWatcherQuery < ProxiesForOwnerAndWatcherQuery
  private

  def accessible_services_ids
    owner.accessible_services.pluck(:id)
  end
end

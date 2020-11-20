# frozen_string_literal: true

class ProxiesForServiceOwnerAndWatcherService < ProxiesForOwnerAndWatcherService
  private

  def accessible_services_ids
    owner.accessible? ? [owner.id] : []
  end
end

# frozen_string_literal: true

class ProxiesForServiceOwnerAndWatcherQuery < ProxiesForOwnerAndWatcherQuery
  private

  def accessible_services_ids
    owner.accessible? ? [owner.id] : []
  end
end

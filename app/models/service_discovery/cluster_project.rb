# frozen_string_literal: true

module ServiceDiscovery
  class ClusterProject < NamespacedClusterResource
    alias namespace name
  end
end

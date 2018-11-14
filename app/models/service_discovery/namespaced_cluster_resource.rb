# frozen_string_literal: true

module ServiceDiscovery
  class NamespacedClusterResource < ClusterResource
    def namespace
      metadata[:namespace]
    end
  end
end

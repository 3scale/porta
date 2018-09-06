# frozen_string_literal: true

module ServiceDiscovery
  module ClusterNamespacesRepresenter
    include ThreeScale::JSONRepresenter

    wraps_collection :namespaces

    items extend: ClusterNamespaceRepresenter
  end
end

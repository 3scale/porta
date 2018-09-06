# frozen_string_literal: true

module ServiceDiscovery
  module ClusterServicesRepresenter
    include ThreeScale::JSONRepresenter

    wraps_collection :services

    items extend: ClusterServiceRepresenter
  end
end

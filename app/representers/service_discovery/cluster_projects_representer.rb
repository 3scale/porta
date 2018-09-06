# frozen_string_literal: true

module ServiceDiscovery
  module ClusterProjectsRepresenter
    include ThreeScale::JSONRepresenter

    wraps_collection :projects

    items extend: ClusterProjectRepresenter
  end
end

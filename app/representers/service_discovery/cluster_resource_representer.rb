# frozen_string_literal: true

module ServiceDiscovery
  module ClusterResourceRepresenter
    extend ActiveSupport::Concern

    included do
      include ThreeScale::JSONRepresenter

      property :metadata
      property :spec
      property :status
    end
  end
end

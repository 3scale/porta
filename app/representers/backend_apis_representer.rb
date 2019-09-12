# frozen_string_literal: true

class BackendApisRepresenter < ThreeScale::CollectionRepresenter
  include Roar::JSON::Collection
  wraps_resource :backend_apis
  items extend: BackendApiRepresenter
end

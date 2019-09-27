# frozen_string_literal: true

class BackendApiConfigsRepresenter < ThreeScale::CollectionRepresenter
  include Roar::JSON::Collection
  items extend: BackendApiConfigRepresenter
end

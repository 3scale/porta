# frozen_string_literal: true

require 'roar/json/collection'

module PoliciesRepresenter
  include ThreeScale::JSONRepresenter
  include Roar::JSON::Collection

  wraps_resource :policies
  items extend: ::PolicyRepresenter
end

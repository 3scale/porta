# frozen_string_literal: true

require 'roar/json/collection'

module PoliciesConfigRepresenter
  include ThreeScale::JSONRepresenter
  include Roar::JSON::Collection

  wraps_resource :policies_config
  items extend: ::PolicyConfigRepresenter
end

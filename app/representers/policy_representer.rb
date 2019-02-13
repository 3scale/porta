# frozen_string_literal: true

module PolicyRepresenter
  include ThreeScale::JSONRepresenter

  wraps_resource

  property :id
  property :name
  property :version
  property :schema
  property :created_at
  property :updated_at
end

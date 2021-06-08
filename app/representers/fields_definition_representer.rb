# frozen_string_literal: true

module FieldsDefinitionRepresenter
  include ThreeScale::JSONRepresenter

  wraps_resource

  property :id
  property :target
  property :name
  property :label
  property :required
  property :hidden
  property :read_only
  property :choices
  property :position
  property :created_at
  property :updated_at
end

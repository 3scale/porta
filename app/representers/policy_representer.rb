# frozen_string_literal: true

module PolicyRepresenter
  include ThreeScale::JSONRepresenter

  wraps_resource

  property :id
  property :name
  property :version
  property :description
  property :summary
  property :schema
  property :created_at
  property :updated_at

  def summary
    schema['summary']
  end

  def description
    schema['description']
  end
end

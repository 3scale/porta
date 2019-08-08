# frozen_string_literal: true

module BackendApiRepresenter
  include ThreeScale::JSONRepresenter

  wraps_resource

  property :id
  property :name
  property :system_name
  property :description
  property :private_endpoint
  property :account_id
  property :created_at
  property :updated_at
end

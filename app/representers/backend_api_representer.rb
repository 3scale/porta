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

  # TODO: links of metrics as part of https://issues.jboss.org/browse/THREESCALE-3209
  # TODO: links of proxy rules as part of https://issues.jboss.org/browse/THREESCALE-3208
  # Right now none of them can be done yet because the routes do not exist yet
end

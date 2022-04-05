# frozen_string_literal: true

module MetricRepresenter
  include ThreeScale::JSONRepresenter

  wraps_resource

  property :id
  property :name, if: ->(*) { !backend_api_metric? }
  property :system_name
  property :friendly_name
  property :description

  property :unit
  property :parent_id, if: ->(*) { method_metric? }

  property :created_at
  property :updated_at

  link :service do
    admin_api_service_url(owner_id) unless backend_api_metric?
  end

  link :backend_api do
    admin_api_backend_api_url(owner_id) if backend_api_metric?
  end

  link :self do
    polymorphic_url([:admin, :api, owner, self])
  end
end

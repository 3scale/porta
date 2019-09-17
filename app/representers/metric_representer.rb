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

  property :created_at
  property :updated_at

  link :service do
    admin_api_service_url(service_id) unless backend_api_metric?
  end

  link :backend_api do
    admin_api_backend_api_url(owner_id) if backend_api_metric?
  end

  link :self do
    public_send("admin_api_#{owner_type.underscore}_metric_url", owner, id)
  end

  def system_name
    backend_api_metric? ? attributes['system_name'] : super
  end
end

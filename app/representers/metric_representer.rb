module MetricRepresenter
  include ThreeScale::JSONRepresenter

  wraps_resource

  property :id
  property :name
  property :system_name
  property :friendly_name
  property :description

  property :unit

  property :created_at
  property :updated_at

  link :service do
    admin_api_service_url(service_id) if service_id
  end

  link :self do
    admin_api_service_metric_url(service_id, id) if service_id && id
  end
end

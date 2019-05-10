module MethodRepresenter
  include ThreeScale::JSONRepresenter

  wraps_resource :method

  property :id
  property :name
  property :system_name
  property :friendly_name
  property :description

  property :created_at
  property :updated_at

  link :parent do
    admin_api_service_metric_url(service_id, parent_id) if service_id && parent_id
  end

  link :self do
    polymorphic_url([:admin, :api, service, parent, :methods], id: id) if service && parent && id
  end
end

# frozen_string_literal: true

module BackendApiConfigRepresenter
  include ThreeScale::JSONRepresenter

  wraps_resource :backend_usage

  property :id
  property :path
  property :service_id
  property :backend_api_id, as: :backend_id

  link :service do
    admin_api_service_url(service_id)
  end

  link :backend_api do
    admin_api_backend_api_url(backend_api_id)
  end
end

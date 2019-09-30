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
  property :usage, decorator: BackendApiConfigsRepresenter

  link :metrics do
    admin_api_backend_api_metrics_path(backend_api_id: id)
  end

  link :mapping_rules do
    admin_api_backend_api_mapping_rules_path(backend_api_id: id)
  end

  def usage
    backend_api_configs.accessible.order(:id)
  end
end

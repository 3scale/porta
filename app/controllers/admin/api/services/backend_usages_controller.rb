# frozen_string_literal: true

class Admin::Api::Services::BackendUsagesController < Admin::Api::Services::BaseController
  self.access_token_scopes = :account_management

  before_action :authorize

  clear_respond_to
  respond_to :json

  wrap_parameters BackendApiConfig
  representer BackendApiConfig

  paginate only: :index

  # swagger
  ##~ sapi = source2swagger.namespace("Account Management API")
  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/services/{service_id}/backend_usages.json"
  ##~ e.responseClass = "List[backend_api_config]"
  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "GET"
  ##~ op.summary    = "Backend Usage List"
  ##~ op.description = "Returns the list of all Backend being used by a Service (Product) with the corresponding path."
  ##~ op.group = "backend_api_config"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_service_id_by_id_name
  #
  def index
    backend_api_configs = service.backend_api_configs.accessible.order(:id).paginate(pagination_params)
    respond_with(backend_api_configs)
  end

  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/services/{service_id}/backend_usages.json"
  ##~ e.responseClass = "backend_api_config"
  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "POST"
  ##~ op.summary    = "Backend Usage Create"
  ##~ op.description = "Adds a Backend to a Service (Product)."
  ##~ op.group = "backend_api_config"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_service_id_by_id_name
  ##~ op.parameters.add :name => "backend_api_id", :description => "Backend to be added to the Service (Product).", :dataType => "string", :required => true, :paramType => "query"
  ##~ op.parameters.add :name => "path", :description => "Path of the Backend for this product.", :dataType => "int", :required => false, :paramType => "query"
  #
  def create
    backend_api_config = service.backend_api_configs.create(create_params)
    respond_with(backend_api_config)
  end

  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/services/{service_id}/backend_usages/{id}.json"
  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "DELETE"
  ##~ op.summary    = "Backend Usage Delete"
  ##~ op.description = "Removes the backend from a Service (Product)."
  ##~ op.group = "backend_api_config"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_service_id_by_id_name
  ##~ op.parameters.add @parameter_backend_api_config_id_by_id
  #
  def destroy
    backend_api_config.destroy
    respond_with(backend_api_config)
  end

  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/services/{service_id}/backend_usages/{id}.json"
  ##~ e.responseClass = "backend_api_config"
  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "PUT"
  ##~ op.summary    = "Backend Usage Update"
  ##~ op.description = "Updates the path of a Backend within the scope of the Service (Product)."
  ##~ op.group = "backend_api_config"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_service_id_by_id_name
  ##~ op.parameters.add @parameter_backend_api_config_id_by_id
  ##~ op.parameters.add :name => "path", :description => "Path of the Backend for this product.", :dataType => "int", :required => false, :paramType => "query"
  #
  def update
    backend_api_config.update(update_params)
    respond_with(backend_api_config)
  end

  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/services/{service_id}/backend_usages/{id}.json"
  ##~ e.responseClass = "backend_api_config"
  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "GET"
  ##~ op.summary    = "Backend Usage Read"
  ##~ op.description = "Show the usage of a Backend within the scope of the Service (Product)."
  ##~ op.group = "backend_api_config"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_service_id_by_id_name
  ##~ op.parameters.add @parameter_backend_api_config_id_by_id
  #
  def show
    respond_with(backend_api_config)
  end

  private

  def backend_api_config
    @backend_api_config ||= service.backend_api_configs.accessible.find(params[:id])
  end

  def create_params
    params.require(:backend_api_config).permit(:path, :backend_api_id).tap do |backend_api_config_params|
      next unless (backend_api_id = backend_api_config_params.delete(:backend_api_id))
      backend_api_config_params[:backend_api] = current_account.backend_apis.accessible.find(backend_api_id)
    end
  end

  def update_params
    params.require(:backend_api_config).permit(:path)
  end

  def authorize
    authorize! :manage, BackendApiConfig
  end
end

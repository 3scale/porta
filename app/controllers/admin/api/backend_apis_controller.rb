# frozen_string_literal: true

class Admin::Api::BackendApisController < Admin::Api::BaseController
  self.access_token_scopes = :account_management

  before_action :authorize

  clear_respond_to
  respond_to :json

  wrap_parameters BackendApi
  representer BackendApi

  paginate only: :index

  ##~ @parameter_backend_api_description = {:name => "description", :description => "Description of the Backend", :dataType => "string", :required => false, :paramType => "query"}


  # swagger
  ##~ @base_path = ""
  #
  ##~ sapi = source2swagger.namespace("Account Management API")
  ##~ sapi.basePath     = @base_path
  ##~ sapi.swaggerVersion = "0.1a"
  ##~ sapi.apiVersion   = "1.0"
  #
  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/backend_apis.json"
  ##~ e.responseClass = "List[backend_api]"
  #
  ##~ op = e.operations.add
  ##~ op.httpMethod = "GET"
  ##~ op.summary = "Backend List"
  ##~ op.description = "Returns the list of backend apis. The results can be paginated."
  ##~ op.group = "backend_api"
  #
  ##~ @parameter_page = {:name => "page", :description => "Page in the paginated list. Defaults to 1.", :dataType => "int", :paramType => "query", :defaultValue => "1"}
  ##~ @parameter_per_page = {:name => "per_page", :description => "Number of results per page. Default and max is 500.", :dataType => "int", :paramType => "query", :defaultValue => "500"}
  ##
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_page
  ##~ op.parameters.add @parameter_per_page
  ##
  #
  def index
    respond_with(current_account.backend_apis.accessible.oldest_first.paginate(pagination_params))
  end

  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/backend_apis.json"
  ##~ e.responseClass = "backend_api"
  #
  ##~ op = e.operations.add
  ##~ op.httpMethod = "POST"
  ##~ op.summary    = "Backend Create"
  ##~ op.description = "Creates a Backend."
  ##~ op.group = "backend_api"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add :name => "name", :description => "Name of the Backend", :dataType => "string", :required => true, :paramType => "query"
  ##~ op.parameters.add @parameter_system_name_by_name
  ##~ op.parameters.add @parameter_backend_api_description
  ##~ op.parameters.add :name => "private_endpoint", :description => "Private Base URL (your API)", :dataType => "string", :required => true, :paramType => "query"
  #
  def create
    backend_api = current_account.backend_apis.create(create_params)
    respond_with(backend_api)
  end

  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/backend_apis/{id}.json"
  ##~ e.responseClass = "backend_api"
  #
  ##~ op = e.operations.add
  ##~ op.httpMethod = "GET"
  ##~ op.summary = "Backend Read"
  ##~ op.description = "Returns a backend."
  ##~ op.group = "backend_api"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_backend_api_id_by_id
  #
  def show
    respond_with(backend_api)
  end

  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/backend_apis/{id}.json"
  ##~ e.responseClass = "backend_api"
  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "PUT"
  ##~ op.summary    = "Backend Update"
  ##~ op.description = "Updates a backend."
  ##~ op.group = "backend_api"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_backend_api_id_by_id
  ##~ op.parameters.add :name => "name", :description => "Name of the Backend", :dataType => "string", :required => false, :paramType => "query"
  ##~ op.parameters.add @parameter_backend_api_description
  ##~ op.parameters.add :name => "private_endpoint", :description => "Private Base URL (your API)", :dataType => "string", :required => false, :paramType => "query"
  #
  def update
    backend_api.update(update_params)
    respond_with(backend_api)
  end

  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/backend_apis/{id}.json"
  ##~ e.responseClass = "backend_api"
  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "DELETE"
  ##~ op.summary    = "Backend Delete"
  ##~ op.description = "Deletes a backend."
  ##~ op.group = "backend_api"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_backend_api_id_by_id
  #
  def destroy
    backend_api.mark_as_deleted
    respond_with(backend_api)
  end

  private

  DEFAULT_PARAMS = %i[name description private_endpoint].freeze
  private_constant :DEFAULT_PARAMS

  def authorize
    return unless current_user # provider_key access
    authorize! action_name.to_sym, BackendApi
  end

  def backend_api
    @backend_api ||= current_account.backend_apis.accessible.find(params[:id])
  end

  def create_params
    params.require(:backend_api).permit(DEFAULT_PARAMS | %i[system_name])
  end

  def update_params
    params.require(:backend_api).permit(DEFAULT_PARAMS)
  end
end

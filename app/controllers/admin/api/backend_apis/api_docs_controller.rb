# frozen_string_literal: true

class Admin::Api::BackendApis::ApiDocsController < Admin::Api::BaseController
  before_action :deny_on_premises_for_master
  before_action :authorize_api_docs
  before_action :find_backend_api

  wrap_parameters ::ApiDocs::Service, name: :api_docs_service, include: ::ApiDocs::Service.attribute_names

  respond_to :json, :xml
  representer collection: ::ApiDocs::ServicesRepresenter, entity: ::ApiDocs::ServiceRepresenter

  # swagger
  ##~ sapi = source2swagger.namespace("Account Management API")
  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/backend_apis/{backend_api_id}/api_docs.json"
  ##~ e.responseClass = "backend_api_active_doc"
  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "GET"
  ##~ op.summary    = "Backend API ActiveDocs Spec List"
  ##~ op.description = "Lists all Backend API ActiveDocs specs"
  ##~ op.group = "backend_api_active_docs"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_backend_api_id
  #
  def index
    respond_with(api_docs)
  end

  # swagger
  ##~ sapi = source2swagger.namespace("Account Management API")
  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/backend_apis/{backend_api_id}/api_docs.json"
  ##~ e.responseClass = "backend_api_active_doc"
  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "POST"
  ##~ op.summary    = "Backend API ActiveDocs Spec Create"
  ##~ op.description = "Creates a new Backend API ActiveDocs spec"
  ##~ op.group = "backend_api_active_docs"
  #
  ##~ @parameter_backend_api_id = {:name => "backend_api_id", :description => "Backend API ID of the Backend API ActiveDocs spec", :dataType => "int", :paramType => "query", :required => false}
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add :name => "name", :description => "Name of the Backend API ActiveDocs spec", :required => true, :dataType => "string", :paramType => "query"
  ##~ op.parameters.add :name => "system_name", :description => "System Name of the Backend API ActiveDocs spec. Only ASCII letters, numbers, dashes and underscores are allowed. If blank, 'system_name' will be generated from the 'name' parameter", :required => false, :dataType => "string", :paramType => "query"
  ##~ op.parameters.add @parameter_backend_api_id
  ##~ op.parameters.add :name => "body", :description => "Backend API ActiveDocs specification in JSON format (based on Swagger)", :dataType => "string", :required => true, :paramType => "query"
  ##~ op.parameters.add :name => "description", :description => "Description of the Backend API ActiveDocs spec", :dataType => "string", :paramType => "query"
  ##~ op.parameters.add :name => "published", :description => "Set to 'true' to publish the spec on the developer portal, or 'false' to hide it. The default value is 'false'", :dataType => "boolean", :paramType => "query"
  ##~ op.parameters.add :name => "skip_swagger_validations", :description => "Set to 'true' to skip validation of the Swagger specification, or 'false' to validate the spec. The default value is 'false'", :dataType => "boolean", :paramType => "query"
  #
  def create
    api_docs_backend_api = api_docs.create(api_docs_params(:system_name), without_protection: true)
    respond_with(api_docs_backend_api)
  end

  # swagger
  ##~ sapi = source2swagger.namespace("Account Management API")
  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/backend_apis/{backend_api_id}/api_docs/{id}.json"
  ##~ e.responseClass = "backend_api_active_doc"
  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "PUT"
  ##~ op.summary    = "Backend API ActiveDocs Spec Update"
  ##~ op.description = "Updates the Backend API ActiveDocs spec by ID"
  ##~ op.group = "backend_api_active_docs"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_active_backend_api_doc_id_by_id
  ##~ op.parameters.add :name => "name", :description => "Name of the Backend API ActiveDocs spec", :required => true, :dataType => "string", :paramType => "query"
  ##~ op.parameters.add @parameter_backend_api_id
  ##~ op.parameters.add :name => "body", :description => "Backend API ActiveDocs specification in JSON format (based on Swagger)", :dataType => "string", :required => true, :paramType => "query"
  ##~ op.parameters.add :name => "description", :description => "Description of the Backend API ActiveDocs spec", :dataType => "string", :paramType => "query"
  ##~ op.parameters.add :name => "published", :description => "Set to 'true' to publish the spec on the developer portal, or 'false' to hide it", :dataType => "boolean", :paramType => "query"
  ##~ op.parameters.add :name => "skip_swagger_validations", :description => "Set to 'true' to skip validation of the Swagger specification, or 'false' to validate the spec", :dataType => "boolean", :paramType => "query"
  #
  def update
    api_docs_backend_api = api_docs.find(params[:id])
    api_docs_backend_api.update(api_docs_params, without_protection: true)
    respond_with(api_docs_backend_api)
  end

  # swagger
  ##~ sapi = source2swagger.namespace("Account Management API")
  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/backend_apis/{backend_api_id}/api_docs/{id}.json"
  ##~ e.responseClass = "backend_api_active_doc"
  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "DELETE"
  ##~ op.summary    = "Backend API ActiveDocs Spec Delete"
  ##~ op.description = "Deletes the Backend API ActiveDocs spec by ID"
  ##~ op.group = "backend_api_active_docs"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_active_backend_api_doc_id_by_id
  ##~ op.parameters.add @parameter_backend_api_id
  #
  def destroy
    api_docs_backend_api = api_docs.find(params[:id])
    api_docs_backend_api.destroy
    respond_with(api_docs_backend_api)
  end

  protected

  def find_backend_api
    @backend_api = current_account.backend_apis.find(params[:backend_api_id])
  end

  def api_docs
    @backend_api.api_docs
  end

  def api_docs_params(*extra_params)
    permit_params = %i[name body description published skip_swagger_validations backend_api_id] + extra_params
    permitted_params = params.require(:api_docs_backend_api).permit(*permit_params)

    permitted_params
  end

  def authorize_api_docs
    authorize! :manage, :plans if current_user
  end
end

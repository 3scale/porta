class Admin::Api::ApiDocsServicesController < Admin::Api::BaseController
  before_action :deny_on_premises_for_master
  before_action :find_api_docs_service, only: [:update, :destroy]

  wrap_parameters ::ApiDocs::Service, name: :api_docs_service, include: ::ApiDocs::Service.attribute_names

  respond_to :json, :xml
  representer collection: ::ApiDocs::ServicesRepresenter, entity: ::ApiDocs::ServiceRepresenter


  # Disable CSRF protection for non xml requests.
  skip_before_action :verify_authenticity_token, if: -> do
    (params.key?(:provider_key) || params.key?(:access_token)) && request.format.json?
  end

  # swagger
  ##~ sapi = source2swagger.namespace("Account Management API")
  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/active_docs.json"
  ##~ e.responseClass = "active_doc"
  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "GET"
  ##~ op.summary    = "ActiveDocs Spec List"
  ##~ op.description = "Lists all ActiveDocs specs"
  ##~ op.group = "active_docs"
  #
  ##~ op.parameters.add @parameter_access_token
  #
  def index
    @api_docs_services = current_account.api_docs_services.all
    respond_with(@api_docs_services)
  end

  # swagger
  ##~ sapi = source2swagger.namespace("Account Management API")
  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/active_docs.json"
  ##~ e.responseClass = "active_doc"
  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "POST"
  ##~ op.summary    = "ActiveDocs Spec Create"
  ##~ op.description = "Creates a new ActiveDocs spec"
  ##~ op.group = "active_docs"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add :name => "name", :description => "Name of the ActiveDocs spec", :required => true, :dataType => "string", :paramType => "query"
  ##~ op.parameters.add :name => "system_name", :description => "System Name of the ActiveDocs spec. Only ASCII letters, numbers, dashes and underscores are allowed. If blank, 'system_name' will be generated from the 'name' parameter", :required => false, :dataType => "string", :paramType => "query"
  ##~ op.parameters.add :name => "body", :description => "ActiveDocs specification in JSON format (based on Swagger)", :dataType => "string", :required => true, :paramType => "query"
  ##~ op.parameters.add :name => "description", :description => "Description of the ActiveDocs spec", :dataType => "string", :paramType => "query"
  ##~ op.parameters.add :name => "published", :description => "Set to 'true' to publish the spec on the developer portal, or 'false' to hide it. The default value is 'false'", :dataType => "boolean", :paramType => "query"
  ##~ op.parameters.add :name => "skip_swagger_validations", :description => "Set to 'true' to skip validation of the Swagger specification, or 'false' to validate the spec. The default value is 'false'", :dataType => "boolean", :paramType => "query"
  #
  def create
    @api_docs_service = current_account.api_docs_services.create(api_docs_params(:system_name), without_protection: true)
    respond_with(@api_docs_service)
  end

  # swagger
  ##~ sapi = source2swagger.namespace("Account Management API")
  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/active_docs/{id}.json"
  ##~ e.responseClass = "active_doc"
  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "PUT"
  ##~ op.summary    = "ActiveDocs Spec Update"
  ##~ op.description = "Updates the ActiveDocs spec by ID"
  ##~ op.group = "active_docs"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_active_doc_id_by_id
  ##~ op.parameters.add :name => "name", :description => "Name of the ActiveDocs spec", :required => false, :dataType => "string", :paramType => "query"
  ##~ op.parameters.add :name => "body", :description => "ActiveDocs specification in JSON format (based on Swagger)", :dataType => "string", :paramType => "query"
  ##~ op.parameters.add :name => "description", :description => "Description of the ActiveDocs spec", :dataType => "string", :paramType => "query"
  ##~ op.parameters.add :name => "published", :description => "Set to 'true' to publish the spec on the developer portal, or 'false' to hide it", :dataType => "boolean", :paramType => "query"
  ##~ op.parameters.add :name => "skip_swagger_validations", :description => "Set to 'true' to skip validation of the Swagger specification, or 'false' to validate the spec", :dataType => "boolean", :paramType => "query"
  #
  def update
    @api_docs_service.update(api_docs_params, without_protection: true)
    respond_with(@api_docs_service)
  end

  # swagger
  ##~ sapi = source2swagger.namespace("Account Management API")
  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/active_docs/{id}.json"
  ##~ e.responseClass = "active_doc"
  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "DELETE"
  ##~ op.summary    = "ActiveDocs Spec Delete"
  ##~ op.description = "Deletes the ActiveDocs spec by ID"
  ##~ op.group = "active_docs"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_active_doc_id_by_id
  #
  def destroy
    @api_docs_service.destroy
    respond_with(@api_docs_service)
  end

  protected

  def api_docs_params(*extra_params)
    permit_params = %i[name body description published skip_swagger_validations service_id] + extra_params
    params.require(:api_docs_service).permit(*permit_params)
  end

  def find_api_docs_service
    @api_docs_service = current_account.api_docs_services.find(params[:id])
  end

end

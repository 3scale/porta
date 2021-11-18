# frozen_string_literal: true

class Admin::Api::ServicesController < Admin::Api::ServiceBaseController
  wrap_parameters Service, include: Service.attribute_names | %w[state_event]
  representer Service

  before_action :deny_on_premises_for_master
  before_action :can_create, only: :create

  paginate only: :index

  # swagger
  ##~ sapi = source2swagger.namespace("Account Management API")
  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/services.xml"
  ##~ e.responseClass = "List[services]"
  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "GET"
  ##~ op.summary    = "Service List"
  ##~ op.description = "Returns the list of all services."
  ##~ op.group = "service"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_page
  ##~ op.parameters.add @parameter_per_page
  #
  def index
    services = accessible_services.includes(:proxy, :account).order(:id).paginate(pagination_params)
    respond_with(services)
  end

  # swagger
  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/services.xml"
  ##~ e.responseClass = "service"
  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "POST"
  ##~ op.summary    = "Service Create"
  ##~ op.description = "Creates a new service."
  ##~ op.group = "service"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add :name => "name", :description => "Name of the service to be created.", :dataType => "string", :required => true, :paramType => "query"
  ##~ op.parameters.add :name => "description", :description => "Description of the service to be created.", :dataType => "string", :required => false, :paramType => "query"
  ##~ op.parameters.add :name => "deployment_option", :description => "Deployment option for the gateway: 'hosted' for APIcast hosted, 'self_managed' for APIcast Self-managed, 'service_mesh_istio' for Istio service mesh option", :dataType => "string", :allowMultiple => false, :required => false, :paramType => "query"
  ##~ op.parameters.add :name => "backend_version", :description => "Authentication mode: '1' for API key, '2' for App Id / App Key, 'oidc' for OpenID Connect", :dataType => "string", :allowMultiple => false, :required => false, :paramType => "query"
  ##~ op.parameters.add @parameter_system_name_by_name
  ##~ op.parameters.add :name => " ", :dataType => "custom", :paramType => "query", :allowMultiple => true, :description => "Extra parameters"
  #
  def create
    service = current_account.services.build
    create_service = ServiceCreator.new(service: service)
    create_service.call(service_params.to_h)
    service.reload if service.persisted? # It has been touched
    respond_with(service)
  end

  # swagger
  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/services/{id}.xml"
  ##~ e.responseClass = "service"
  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "GET"
  ##~ op.summary    = "Service Read"
  ##~ op.description = "Returns the service by id."
  ##~ op.group = "service"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_service_id_by_id
  #
  def show
    respond_with(service)
  end

  ##~ op            = e.operations.add
  ##~ op.httpMethod = "PUT"
  ##~ op.summary    = "Service Update"
  ##~ op.description = "Update the service."
  ##~ op.group = "service"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_service_id_by_id
  ##~ op.parameters.add :name => "name", :description => "New name for the service.", :dataType => "string", :allowMultiple => false, :required => false, :paramType => "query"
  ##~ op.parameters.add :name => "description", :description => "New description for the service.", :dataType => "string", :allowMultiple => false, :required => false, :paramType => "query"
  ##~ op.parameters.add :name => "support_email", :description => "New support email.", :dataType => "string", :allowMultiple => false, :required => false, :paramType => "query"
  ##~ op.parameters.add :name => "deployment_option", :description => "Deployment option for the gateway: 'hosted' for APIcast hosted, 'self_managed' for APIcast Self-managed, 'service_mesh_istio' for Istio service mesh option", :dataType => "string", :allowMultiple => false, :required => false, :paramType => "query"
  ##~ op.parameters.add :name => "backend_version", :description => "Authentication mode: '1' for API key, '2' for App Id / App Key, 'oidc' for OpenID Connect", :dataType => "string", :allowMultiple => false, :required => false, :paramType => "query"
  ##~ op.parameters.add :name => " ", :dataType => "custom", :paramType => "query", :allowMultiple => true, :description => "Extra parameters"
  #
  def update
    service.update(service_params.to_h)

    respond_with(service)
  end

  ##~ op            = e.operations.add
  ##~ op.httpMethod = "DELETE"
  ##~ op.summary    = "Service Delete"
  ##~ op.description = "Delete the service. Deleting a service removes all applications and service subscriptions."
  ##~ op.group = "service"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_service_id_by_id
  #
  def destroy
    authorize!(:destroy, service) if current_user
    service.mark_as_deleted!

    respond_with(service)
  end

  protected

  def can_create
    authorize!(:create, Service) if current_user
    head :forbidden unless current_account.can_create_service?
  end

  def service_params
    permitted_params = [:name, :system_name, :description, :support_email, :deployment_option, :backend_version,
                        :intentions_required, :buyers_manage_apps, :referrer_filters_required,
                        :buyer_can_select_plan, :buyer_plan_change_permission, :buyers_manage_keys,
                        :buyer_key_regenerate_enabled, :mandatory_app_key, :custom_keys_enabled, :state_event,
                        :txt_support, :terms,
                        {notification_settings: [web_provider: [], email_provider: [], web_buyer: [], email_buyer: []]}]
    params.require(:service).permit(*permitted_params)
  end

  def service
    @service ||= accessible_services.find(params[:id])
  end
end

class Admin::Api::ApplicationsController < Admin::Api::BaseController
  representer ::Cinstance

  paginate only: :index
  # swagger
  ##~ sapi = source2swagger.namespace("Account Management API")
  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/applications.xml"
  ##~ e.responseClass = "List[applications]"
  #
  ##~ op            = e.operations.add
  ##~ op.nickname   ="applications"
  ##~ op.httpMethod = "GET"
  ##~ op.summary    = "Application List (all services)"
  ##~ op.description = "Returns the list of applications across all services. Note that applications are scoped by service and can be paginated."
  ##~ op.group = "application"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_page
  ##~ op.parameters.add @parameter_per_page
  ##~ op.parameters.add :name => "active_since", :description => "Filter date", :dataType => "string", :allowMultiple => false, :required => false, :paramType => "query", :threescale_name => "active_since"
  ##~ op.parameters.add :name => "inactive_since", :description => "Filter date", :dataType => "string", :allowMultiple => false, :required => false, :paramType => "query", :threescale_name => "inactive_since"
  ##~ op.parameters.add :name => "service_id", :description => "Filter by service", :dataType => "string", :allowMultiple => false, :required => false, :paramType => "query", :threescale_name => "service_id"
  ##~ op.parameters.add :name => "plan_id", :description => "Filter by plan", :dataType => "string", :allowMultiple => false, :required => false, :paramType => "query", :threescale_name => "plan_id"
  ##~ op.parameters.add :name => "plan_type", :description => "Filter by plan type", :dataType => "string", :allowableValues => {:values => ["free", "paid"], :valueType => "LIST"}, :allowMultiple => false, :required => false, :paramType => "query", :threescale_name => "plan_type"
  #

  def index
    apps = applications.scope_search(search)
           .serialization_preloading.paginate(:page => current_page, :per_page => per_page)
    respond_with(apps)
  end

  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/applications/find.xml"
  ##~ e.responseClass = "application"
  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "GET"
  ##~ op.summary    = "Application Find"
  ##~ op.description = "Finds an application by keys used on the integration of your API and 3scale's Service Management API or by application ID."
  ##~ op.group = "application"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_application_id_by_name
  ##~ op.parameters.add :name => "user_key", :description => "user_key of the application (for user_key authentication mode).", :dataType => "string", :allowMultiple => false, :required => false, :paramType => "query", :threescale_name => "user_keys"
  ##~ op.parameters.add :name => "app_id", :description => "app_id of the application (for app_id/app_key and oauth authentication modes).", :dataType => "string", :allowMultiple => false, :required => false, :paramType => "query", :threescale_name => "app_ids"
  ##~ op.parameters.add :name => "service_id", :description => "Filter by service", :dataType => "string", :allowMultiple => false, :required => false, :paramType => "query", :threescale_name => "service_id"
  #
  def find
    respond_with(application)
  end

  private

  def application_filter_params
    params.permit(:active_since, :inactive_since)
  end

  def applications
    @applications ||= begin
      cinstances = current_account.provided_cinstances.where(service: accessible_services)
      if (service_id = params[:service_id])
        cinstances = cinstances.where(service_id: service_id)
      end
      cinstances
    end
  end

  def application
    @application ||= case

                     when user_key = params[:user_key]
      # TODO: these scopes should be in model layer
      # but there is scope named by_user_key already
      applications.joins(:service).where("(services.backend_version = '1' AND cinstances.user_key = ?)", user_key).first!

                     when app_id = params[:app_id]
      applications.joins(:service).where("(services.backend_version <> '1' AND cinstances.application_id = ?)", app_id).first!

                     else
      applications.find(params[:application_id] || params[:id])
    end
  end

end

class Admin::Api::BuyersApplicationsController < Admin::Api::BuyersBaseController
  representer Cinstance

  before_action :find_or_create_service_contract, :only => :create

  ##~ sapi = source2swagger.namespace("Account Management API")
  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/accounts/{account_id}/applications.xml"
  ##~ e.responseClass = "List[applications]"
  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "GET"
  ##~ op.summary    = "Application List"
  ##~ op.description = "Returns the list of application of an account."
  ##~ op.group = "application"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_account_id_by_id_name
  #
  def index
    respond_with(applications.by_state(params[:state]))
  end

  ##~ op = e.operations.add
  ##~ op.httpMethod = "POST"
  ##~ op.summary    = "Application Create"
  ##~ op.description = "Create an application. The application object can be extended with Fields Definitions in the Admin Portal where you can add/remove fields, for instance token (string), age (int), third name (string optional), etc."
  ##~ op.group = "application"
  #
  ##~ @parameter_plan_id = { :name => "plan_id", :description => "ID of the application plan.", :dataType => "int", :required => true, :paramType => "query", :threescale_name => "application_plan_ids"}
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_account_id_by_id_name
  ##~ op.parameters.add @parameter_plan_id
  ##~ op.parameters.add :name => "name", :description => "Name of the application to be created.", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.parameters.add :name => "description", :description => "Description of the application to be created.", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  ##~ op.parameters.add :name => "user_key", :description => "User Key (API Key) of the application to be created.", :dataType => "string", :allowMultiple => false, :required => false, :paramType => "query"
  ##~ op.parameters.add :name => "application_id", :description => "App ID or Client ID (for OAuth and OpenID Connect authentication modes) of the application to be created.", :dataType => "string", :allowMultiple => false, :required => false, :paramType => "query"
  ##~ op.parameters.add :name => "application_key", :description => "App Key(s) or Client Secret (for OAuth and OpenID Connect authentication modes) of the application to be created.", :dataType => "string", :allowMultiple => true, :required => false, :paramType => "query"
  ##~ op.parameters.add :name => "redirect_url", :description => "Redirect URL for the OAuth request.", :dataType => "string", :allowMultiple => false, :required => false, :paramType => "query"
  ##~ op.parameters.add :name => "first_traffic_at", :description => "Timestamp of the first call made by the application.", :dataType => "string", :allowMultiple => false, :required => false, :paramType => "query"
  ##~ op.parameters.add :name => "first_daily_traffic_at", :description => "Timestamp of the first call on the last day when traffic was registered for the application ('Traffic On').", :dataType => "string", :allowMultiple => false, :required => false, :paramType => "query"
  ##~ op.parameters.add @parameter_extra

  def create
    application = applications.new(user_account: buyer, plan: application_plan, create_origin: "api")
    application.unflattened_attributes = application_params
    application.user_key = params[:user_key] if params[:user_key]
    application.application_id = params[:application_id] if params[:application_id]

    Array(params[:application_key]).each do |key|
      application.application_keys.build(value: key)
    end

    application.save

    respond_with(application)
  end

  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/accounts/{account_id}/applications/{id}.xml"
  ##~ e.responseClass = "application"
  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "GET"
  ##~ op.summary    = "Application Read"
  ##~ op.description = "Returns the application by id."
  ##~ op.group = "application"
  #
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_account_id_by_id_name
  ##~ op.parameters.add @parameter_application_id_by_id
  #
  def show
    respond_with application
  end

  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "PUT"
  ##~ op.summary    = "Application Update"
  ##~ op.description = "Updates an application. All fields of the application object can be updated except the id and the app_id (when using OAuth or app_id/app_key authentication pattern)."
  ##~ op.group = "application"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_account_id_by_id_name
  ##~ op.parameters.add @parameter_application_id_by_id
  ##~ op.parameters.add :name => "name", :description => "Name of the application.", :dataType => "string", :required => false, :paramType => "query"
  ##~ op.parameters.add :name => "description", :description => "Description of the application.", :dataType => "string", :required => false, :paramType => "query"
  ##~ op.parameters.add :name => "redirect_url", :description => "Redirect URL for the OAuth request.", :dataType => "string", :allowMultiple => false, :required => false, :paramType => "query"
  ##~ op.parameters.add :name => "first_traffic_at", :description => "Timestamp of the first call made by the application.", :dataType => "string", :allowMultiple => false, :required => false, :paramType => "query"
  ##~ op.parameters.add :name => "first_daily_traffic_at", :description => "Timestamp of the first call on the last day when traffic was registered for the application ('Traffic On').", :dataType => "string", :allowMultiple => false, :required => false, :paramType => "query"
  ##~ op.parameters.add @parameter_extra
  #
  def update
    application.unflattened_attributes = flat_params
    application.user_key = params[:user_key] if params[:user_key]

    application.save

    respond_with application
  end

  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "DELETE"
  ##~ op.summary    = "Application Delete"
  ##~ op.description = "Deletes the application."
  ##~ op.group = "application"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_account_id_by_id_name
  ##~ op.parameters.add @parameter_application_id_by_id
  #
  def destroy
    application.destroy
    respond_with application
  end

  # FIXME: we should not document and remove this one, we have on find global already.
  # swagger
  ## e = sapi.apis.add
  ## e.path = "/admin/api/accounts/{account_id}/applications/find.xml"
  ## e.responseClass = "application"
  #
  ## op            = e.operations.add
  ## op.httpMethod = "GET"
  ## op.summary    = "Application Find"
  ## op.description = "Finds an application of a partner account by user_key or app_id, depending on the authentication mode."
  ## op.group = "application"
  #
  ## op.parameters.add @access_token
  ## op.parameters.add @application_id_by_id_name
  ## op.parameters.add :name => "user_key", :description => "user_key of the application (for user_key authentication mode).", :dataType => "string", :allowMultiple => false, :required => false, :paramType => "query"
  ## op.parameters.add :name => "app_id", :description => "app_id of the application (for app_id/app_key and oauth authentication modes).", :dataType => "string", :allowMultiple => false, :required => false, :paramType => "query"
  #
  def find
    application = buyer.bought_cinstances.joins(:service).where("(services.backend_version = '1' AND cinstances.user_key = ?) OR (services.backend_version <> '1' AND cinstances.application_id = ?)", params[:user_key], params[:app_id]).first!

    respond_with application
  end

  # swagger
  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/accounts/{account_id}/applications/{id}/change_plan.xml"
  ##~ e.responseClass = "application"
  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "PUT"
  ##~ op.summary    = "Application Change Plan"
  ##~ op.description = "Changes the application plan of an application."
  ##~ op.group = "application"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_account_id_by_id_name
  ##~ op.parameters.add @parameter_application_id_by_id
  ##~ op.parameters.add :name => "plan_id", :description => "ID of the new application plan.", :dataType => "int", :paramType => "query", :required => true, :threescale_name => "application_plan_ids"
  #
  def change_plan
    application_plan = same_service_application_plans.find(params[:plan_id])
    plan = application.change_plan!(application_plan)

    # changing a plan to same returns nil so we just return existing plan here:
    respond_with(application, serialize: plan || application_plan, representer: ApplicationPlanRepresenter)
  end

  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/accounts/{account_id}/applications/{id}/customize_plan.xml"
  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "PUT"
  ##~ op.summary    = "Application Create Plan Customization"
  ##~ op.description = "Creates a customized application plan for the application."
  ##~ op.group = "application"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_account_id_by_id_name
  ##~ op.parameters.add @parameter_application_id_by_id
  #
  def customize_plan
    plan = application.customize_plan!

    respond_with(plan, representer: ApplicationPlanRepresenter)
  end

  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/accounts/{account_id}/applications/{id}/decustomize_plan.xml"
  ##~ e.responseClass = "application"
  ##~ @desc         = "Decustomizes the plan of an application."
  ##~ e.description = @desc
  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "PUT"
  ##~ op.summary    = "Application Delete Plan Customization"
  ##~ op.description = "Deletes the customized application plan of the application. After removing the customization the application will be constrained by the original application plan."
  ##~ op.group = "application"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_account_id_by_id_name
  ##~ op.parameters.add @parameter_application_id_by_id
  #
  def decustomize_plan
    plan = application.decustomize_plan!

    respond_with(plan, representer: ApplicationPlanRepresenter)
  end

  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/accounts/{account_id}/applications/{id}/accept.xml"
  ##~ e.responseClass = "application"
  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "PUT"
  ##~ op.summary    = "Application Accept"
  ##~ op.description = "Accepts an application (changes the state to live). Once the state is live the application can be used on API requests."
  ##~ op.group = "application"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_account_id_by_id_name
  ##~ op.parameters.add @parameter_application_id_by_id
  #
  def accept
    application.accept

    respond_with application
  end

  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/accounts/{account_id}/applications/{id}/suspend.xml"
  ##~ e.responseClass = "application"
  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "PUT"
  ##~ op.summary    = "Application Suspend"
  ##~ op.description = "Suspends an application (changes the state to suspended). Suspending an application will stop the application from authorizing API requests."
  ##~ op.group = "application"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_account_id_by_id_name
  ##~ op.parameters.add @parameter_application_id_by_id
  #
  def suspend
    application.suspend

    respond_with application
  end

  # swagger
  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/accounts/{account_id}/applications/{id}/resume.xml"
  ##~ e.responseClass = "application"
  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "PUT"
  ##~ op.summary    = "Application Resume"
  ##~ op.description = "Resume a suspended application. Once a suspended application is resumed it will be authorized on API requests."
  ##~ op.group = "application"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_account_id_by_id_name
  ##~ op.parameters.add @parameter_application_id_by_id
  #
  def resume
    application.resume

    respond_with application
  end

  protected

  def applications
    # bullet says that it detected N+1 queries and recommended following eager loading:
    @applications ||= accessible_bought_cinstances.includes(:user_account, :plan, :service)
  end

  def same_service_application_plans
    accessible_application_plans.where(issuer: application.service)
  end

  def application
    @application ||= applications.find params[:id]
  end

  def application_plan
    @application_plan ||= accessible_application_plans.find(params[:plan_id])
  end

  def application_params
    flat_params.slice(*application_attributes)
  end

  def application_attributes
    current_account.fields.for(Cinstance) + %w|user_key application_id|
  end

  def flat_params
    super.except(:account_id)
  end

  def find_or_create_service_contract
    unless current_account.find_or_create_service_contract(buyer, application_plan.service)
      render_error 'You cannot subscribe to that service.', status: :unprocessable_entity
    end
  end

end

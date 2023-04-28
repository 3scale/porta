class Admin::Api::BuyersApplicationsController < Admin::Api::BuyersBaseController
  representer Cinstance

  before_action :find_or_create_service_contract, :only => :create

  # Application List
  # GET /admin/api/accounts/{account_id}/applications.xml
  def index
    respond_with(applications.by_state(params[:state]))
  end

  # Application Create
  # POST /admin/api/accounts/{account_id}/applications.xml
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

  # Application Read
  # GET /admin/api/accounts/{account_id}/applications/{id}.xml
  def show
    respond_with application
  end

  # Application Update
  # PUT /admin/api/accounts/{account_id}/applications/{id}.xml
  def update
    application.unflattened_attributes = flat_params
    application.user_key = params[:user_key] if params[:user_key]

    application.save

    respond_with application
  end

  # Application Delete
  # DELETE /admin/api/accounts/{account_id}/applications/{id}.xml
  def destroy
    application.destroy
    respond_with application
  end

  # FIXME: we should not document and remove this one, we have on find global already.
  # Application Find
  # GET /admin/api/accounts/{account_id}/applications/find.xml
  def find
    application = buyer.bought_cinstances.joins(:service).where("(services.backend_version = '1' AND cinstances.user_key = ?) OR (services.backend_version <> '1' AND cinstances.application_id = ?)", params[:user_key], params[:app_id]).first!

    respond_with application
  end

  # Application Change Plan
  # PUT /admin/api/accounts/{account_id}/applications/{id}/change_plan.xml
  def change_plan
    plan = application.change_plan(application_plan)

    # changing a plan to same returns nil so we just return existing plan here:
    respond_with(application, serialize: plan || application_plan, representer: ApplicationPlanRepresenter)
  end

  # Application Create Plan Customization
  # PUT /admin/api/accounts/{account_id}/applications/{id}/customize_plan.xml
  def customize_plan
    plan = application.customize_plan!

    respond_with(plan, representer: ApplicationPlanRepresenter)
  end

  # Application Delete Plan Customization
  # PUT /admin/api/accounts/{account_id}/applications/{id}/decustomize_plan.xml
  def decustomize_plan
    plan = application.decustomize_plan!

    respond_with(plan, representer: ApplicationPlanRepresenter)
  end

  # Application Accept
  # PUT /admin/api/accounts/{account_id}/applications/{id}/accept.xml
  def accept
    application.accept

    respond_with application
  end

  # Application Suspend
  # PUT /admin/api/accounts/{account_id}/applications/{id}/suspend.xml
  def suspend
    application.suspend

    respond_with application
  end

  # Application Resume
  # PUT /admin/api/accounts/{account_id}/applications/{id}/resume.xml
  def resume
    application.resume

    respond_with application
  end

  protected

  def applications
    # bullet says that it detected N+1 queries and recommended following eager loading:
    @applications ||= accessible_bought_cinstances.includes(:user_account, :plan, :service)
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

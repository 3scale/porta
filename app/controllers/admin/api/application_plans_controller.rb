# frozen_string_literal: true

class Admin::Api::ApplicationPlansController < Admin::Api::ServiceBaseController
  representer ApplicationPlan
  wrap_parameters ApplicationPlan, include: ApplicationPlan.attribute_names | %w[state_event]

  before_action :deny_on_premises_for_master
  before_action :authorize_manage_plans, only: %i[create destroy]

  # Application Plan List (all services)
  # GET /admin/api/application_plans.xml

  # Application Plan List
  # GET /admin/api/services/{service_id}/application_plans.xml
  def index
    respond_with(application_plans.includes(:original, :issuer))
  end

  # Application Plan Create
  # POST /admin/api/services/{service_id}/application_plans.xml
  def create
    application_plan = application_plans.create(application_plan_create_params)
    respond_with(application_plan)
  end

  # Application Plan Read
  # GET /admin/api/services/{service_id}/application_plans/{id}.xml
  def show
    respond_with(application_plan)
  end

  # Application Plan Update
  # PUT /admin/api/services/{service_id}/application_plans/{id}.xml
  def update
    application_plan.update(application_plan_update_params)
    respond_with(application_plan)
  end

  # Application Plan Delete
  # DELETE /admin/api/services/{service_id}/application_plans/{id}.xml
  def destroy
    application_plan.destroy

    respond_with(application_plan)
  end

  # Application Plan Set to Default
  # PUT /admin/api/services/{service_id}/application_plans/{id}/default.xml
  def default
    service.update_attribute(:default_application_plan, application_plan)
    respond_with(application_plan)
  end

  protected

  DEFAULT_PARAMS = %i[name state_event description approval_required trial_period_days
                      cost_per_month setup_fee].freeze

  def application_plan_update_params
    params.require(:application_plan).permit(DEFAULT_PARAMS)
  end

  def application_plan_create_params
    params.require(:application_plan).permit(DEFAULT_PARAMS | %i[system_name])
  end

  def application_plans
    @application_plans ||= scope.application_plans.where(issuer: accessible_services)
  end

  def application_plan
    @application_plan ||= application_plans.find(params[:id])
  end

  def authorize_manage_plans
    Ability.new(current_account.admins.first).authorize!(:manage, :plans)
  end
end

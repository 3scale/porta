# frozen_string_literal: true

class Admin::Api::ServicePlansController < Admin::Api::ServiceBaseController
  wrap_parameters ServicePlan, include: ServicePlan.attribute_names | %w[state_event]
  representer ServicePlan

  before_action :authorize_service_plans!

  # Service Plan List (all services)
  # GET /admin/api/service_plans.xml

  # Service Plan List
  # GET /admin/api/services/{id}/service_plans.xml
  def index
    respond_with(service_plans)
  end

  # Service Plan Create
  # POST /admin/api/services/{id}/service_plans.xml
  def create
    service_plan = service_plans.create(service_plan_create_params)
    respond_with(service_plan)
  end

  # Service Plan Read
  # GET /admin/api/services/{service_id}/service_plans/{id}.xml
  def show
    respond_with(service_plan)
  end

  # Service Plan Update
  # PUT /admin/api/services/{service_id}/service_plans/{id}.xml
  def update
    service_plan.update(service_plan_update_params)
    respond_with(service_plan)
  end

  # Service Plan Delete
  # DELETE /admin/api/services/{service_id}/service_plans/{id}.xml
  def destroy
    service_plan.destroy

    respond_with(service_plan)
  end

  # Service Plan Set to Default
  # PUT /admin/api/services/{service_id}/service_plans/{id}/default.xml
  def default
    service.update_attribute(:default_service_plan, service_plan)

    respond_with(service_plan)
  end

  protected

  DEFAULT_PARAMS = %i[name state_event approval_required].freeze

  def service_plan_update_params
    params.require(:service_plan).permit(DEFAULT_PARAMS)
  end

  def service_plan_create_params
    params.require(:service_plan).permit(DEFAULT_PARAMS | %i[system_name])
  end

  def service_plans
    @service_plans ||= scope.service_plans.where(issuer: accessible_services)
  end

  def service_plan
    @service_plan ||= service_plans.find(params[:id])
  end

end

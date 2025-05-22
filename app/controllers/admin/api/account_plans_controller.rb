# frozen_string_literal: true

class Admin::Api::AccountPlansController < Admin::Api::BaseController
  representer AccountPlan
  wrap_parameters AccountPlan, include: AccountPlan.attribute_names | %w[state_event]

  before_action :authorize_account_plans!

  # Account Plan List
  # GET /admin/api/account_plans.xml
  def index
    respond_with(account_plans)
  end

  # Account Plan Create
  # POST /admin/api/account_plans.xml
  def create
    account_plan = account_plans.create(account_plan_create_params)
    respond_with(account_plan)
  end

  # Account Plan Read
  # GET /admin/api/account_plans/{id}.xml
  def show
    respond_with(account_plan)
  end

  # Account Plan Update
  # PUT /admin/api/account_plans/{id}.xml
  def update
    account_plan.update(account_plan_update_params)
    respond_with(account_plan)
  end

  # Account Plan Delete
  # DELETE /admin/api/account_plans/{id}.xml
  def destroy
    account_plan.destroy

    respond_with(account_plan)
  end

  # Account Plan set to Default
  # PUT /admin/api/account_plans/{id}/default.xml
  def default
    current_account.update_attribute(:default_account_plan, account_plan)

    respond_with(account_plan)
  end

  private

  DEFAULT_PARAMS = %i[name state_event approval_required].freeze

  def account_plan_update_params
    params.require(:account_plan).permit(DEFAULT_PARAMS)
  end

  def account_plan_create_params
    params.require(:account_plan).permit(DEFAULT_PARAMS | %i[system_name])
  end

  def account_plan
    @account_plan ||= account_plans.find(params[:id])
  end

  def account_plans
    @account_plans ||= current_account.account_plans
  end

end

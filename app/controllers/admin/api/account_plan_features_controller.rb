class Admin::Api::AccountPlanFeaturesController < Admin::Api::FeaturingsBaseController

  before_action :authorize_account_plans!

  # Account Plan Feature List | Create
  # GET | POST /admin/api/account_plans/{account_plan_id}/features.xml

  # Account Plan Feature Delete
  # DELETE /admin/api/account_plans/{account_plan_id}/features/{id}.xml

  protected

  def plan
    @plan ||= current_account.account_plans.find(params[:account_plan_id])
  end

  def features
    @features ||= plan.features
  end
end

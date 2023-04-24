class Admin::Api::ServicePlanFeaturesController < Admin::Api::FeaturingsBaseController

  before_action :authorize_service_plans!

  # Service Plan Feature List | Create | Update
  # GET | POST | DELETE /admin/api/service_plans/{service_plan_id}/features.xml

  protected

  def plan
    @plan ||= current_account.service_plans
                .where(issuer: accessible_services)
                .find(params[:service_plan_id])
  end

end

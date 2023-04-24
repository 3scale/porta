class Admin::Api::ApplicationPlanFeaturesController < Admin::Api::FeaturingsBaseController

  # Application Plan Feature List | Create | Update
  # GET | POST | DELETE /admin/api/application_plans/{application_plan_id}/features.xml

  protected

  def plan
    @plan ||= accessible_application_plans.find(params[:application_plan_id])
  end
end

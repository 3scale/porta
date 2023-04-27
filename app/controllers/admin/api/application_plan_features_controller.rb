class Admin::Api::ApplicationPlanFeaturesController < Admin::Api::FeaturingsBaseController

  # Application Plan Feature List | Create
  # GET | POST /admin/api/application_plans/{application_plan_id}/features.xml

  # Application Plan Feature Delete
  # DELETE /admin/api/application_plans/{application_plan_id}/features/{id}.xm

  protected

  def plan
    @plan ||= accessible_application_plans.find(params[:application_plan_id])
  end
end

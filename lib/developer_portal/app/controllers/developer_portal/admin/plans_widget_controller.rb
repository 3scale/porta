class DeveloperPortal::Admin::PlansWidgetController < DeveloperPortal::BaseController

  layout false

  def index
    if params[:application_id]
      @application = current_account.bought_cinstances.find params[:application_id]
      @plan        = @application.plan
      @service     = @application.service
    else
      @service = site_account.services.find params[:service_id]
    end

    @wizard = params[:wizard].to_s == 'true'
    @plans = @service.application_plans.not_custom.published.to_a
    @plans.delete @plan
  end

end

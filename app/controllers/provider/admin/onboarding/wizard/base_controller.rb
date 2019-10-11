class Provider::Admin::Onboarding::Wizard::BaseController < FrontendController
  layout "wizard"

  delegate :onboarding, to: :current_account

  helper_method :apiap?

  def track_step(step)
    analytics.track('Wizard Step', step: step.to_s)
  end

  protected

  def apiap?
    site_account.provider_can_use? :api_as_product
  end

  def service
    current_account.first_service!
  end
end

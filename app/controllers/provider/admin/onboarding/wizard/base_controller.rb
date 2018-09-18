class Provider::Admin::Onboarding::Wizard::BaseController < FrontendController
  layout "wizard"

  delegate :onboarding, to: :current_account

  def track_step(step)
    analytics.track('Wizard Step', step: step.to_s)
  end
end

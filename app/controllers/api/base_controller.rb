class Api::BaseController < FrontendController

  private

  helper_method :bubbles
  delegate :onboarding, to: :current_account

  def bubbles
    onboarding.persisted? ? onboarding.bubbles : []
  end
end

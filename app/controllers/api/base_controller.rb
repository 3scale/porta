class Api::BaseController < FrontendController

  private

  helper_method :bubbles
  delegate :onboarding, to: :current_account

  def activate_submenu
      activate_menu :submenu => current_account.multiservice? ? :services : @service.name
  end

  def bubbles
    onboarding.persisted? ? onboarding.bubbles : []
  end
end

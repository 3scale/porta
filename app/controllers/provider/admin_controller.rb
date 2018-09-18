class Provider::AdminController < FrontendController
  before_action :ensure_provider_domain

  def show
    flash.keep

    if start_onboarding_wizard
      redirect_to provider_admin_onboarding_wizard_root_path
    elsif has_permission? && onboarding_active?
      redirect_to admin_services_path
    else
      redirect_back_or_default provider_admin_dashboard_path
    end
  end

  protected

  def start_onboarding_wizard
    started = onboarding.start_wizard
  rescue StateMachines::InvalidTransition => error
    System::ErrorReporting.report_error(error)

    false
  ensure
    analytics.track('Wizard Step', step: 'started') if started
  end

  def onboarding_active?
    onboarding.active?
  end

  def has_permission?
    can? :manage, :plans
  end

  def onboarding
    current_account.onboarding
  end

  def can_start_onboarding_wizard?
    onboarding.can_start_wizard?
  end
end

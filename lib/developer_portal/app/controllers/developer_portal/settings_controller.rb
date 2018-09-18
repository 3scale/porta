# This controller is deprecated and should be removed once _footer.erb is gone.
# footer.erb will be gone when {{ footer }} liqud tag will be gone
class DeveloperPortal::SettingsController < DeveloperPortal::BaseController

  liquify

  skip_before_action :login_required

  def terms
    #fast fix, should be better to find the service by url or something
    @service = site_account.first_service!
    redirect_to(root_path) unless @service.has_terms?
  end

  def privacy
    @settings = site_account.settings
    redirect_to(root_path) unless @settings.has_privacy_policy?
  end

  def refunds
    @settings = site_account.settings
    redirect_to(root_path) unless @settings.has_refund_policy?
  end
end

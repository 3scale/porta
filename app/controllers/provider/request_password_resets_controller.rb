# frozen_string_literal: true

class Provider::RequestPasswordResetsController < FrontendController
  layout 'provider/login'

  skip_before_action :login_required

  before_action :ensure_provider_domain
  before_action :find_provider

  def new
    redirect_to provider_admin_dashboard_url if logged_in?
  end

  private

  def find_provider
    @provider ||= site_account_request.find_provider
  end
end

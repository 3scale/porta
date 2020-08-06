class Finance::Provider::BaseController < FrontendController

  include Finance::ControllerRequirements

  activate_menu :audience, :finance

  before_action :ensure_provider
  before_action :authorize_finance

  layout 'provider'

end

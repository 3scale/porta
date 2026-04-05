class Provider::Admin::BaseController < FrontendController
  before_action :ensure_provider_domain
end

class Provider::BaseController < FrontendController
  before_action :ensure_master_domain
end

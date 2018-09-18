module DeveloperPortal
  class Admin::ServicesController < DeveloperPortal::BaseController

    before_action :authorize_services
    activate_menu :dashboard

    liquify prefix: 'services'

    def index
    end

    private

    def authorize_services
      authorize! :manage, :service_contracts
    end

  end
end

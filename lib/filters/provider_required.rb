module Filters::ProviderRequired

  def provider_required(options = {})
    before_action :provider_required, options
    include ControllerMethods
  end

  module ControllerMethods
    protected

    def provider_required
      if current_account.nil? || !current_account.provider?
        render_error 'Access denied', :status => :forbidden
        false
      else
        true
      end
    end
  end
end

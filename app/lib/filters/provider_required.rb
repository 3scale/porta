# frozen_string_literal: true

module Filters::ProviderRequired

  def provider_required(options = {})
    before_action :provider_required, options
    include ControllerMethods
  end

  module ControllerMethods
    protected

    def provider_required
      return true if current_account&.provider?

      render_error 'Access denied', status: :forbidden
      false
    end
  end
end

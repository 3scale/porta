# frozen_string_literal: true

class Provider::Admin::QuickstartsController < FrontendController
  before_action :hide_quickstarts

  activate_menu :quickstarts

  layout 'provider'

  def show; end

  private

  def hide_quickstarts
    raise ActionController::RoutingError, '' unless Features::QuickstartsConfig.enabled?
  end
end

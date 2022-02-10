# frozen_string_literal: true

class Provider::Admin::QuickStartsController < FrontendController
  before_action :hide_quicks_tarts

  activate_menu :quick_starts

  layout 'provider'

  def show; end

  private

  def hide_quicks_tarts
    raise ActionController::RoutingError, '' unless provider_can_use?(:quick_starts)
  end
end

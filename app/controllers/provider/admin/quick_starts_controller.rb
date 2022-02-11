# frozen_string_literal: true

class Provider::Admin::QuickStartsController < FrontendController
  before_action :hide_quick_starts

  activate_menu :quick_starts

  layout 'provider'

  def show; end

  private

  def hide_quick_starts
    raise ActionController::RoutingError, '' unless provider_can_use?(:quick_starts)
  end
end

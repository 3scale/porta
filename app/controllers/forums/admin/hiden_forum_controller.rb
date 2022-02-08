# frozen_string_literal: true

class Forums::Admin::HidenForumController < FrontendController
  before_action :hide_forum

  private

  def hide_forum
    raise ActionController::RoutingError, '' unless current_account&.provider_can_use?(:forum)
  end
end

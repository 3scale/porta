class Provider::Admin::DashboardsController < FrontendController
  before_action :ensure_provider_domain

  activate_menu :dashboard
  layout 'provider'

  def show
    @service    = find_service
    @metrics    = @service.metrics.top_level
    @cinstances = @service.cinstances.latest
    # Would be cool to
    #
    # .scoped(:include => [ :message => [ :sender ]])
    #
    # but 'Cannot eagerly load the polymorphic association :sender'
    @services           = current_user.accessible_services
    @messages_presenter = current_presenter
    @unread_messages_presenter = unread_messages_presenter
  end

  include DashboardTimeRange
  helper_method :current_range, :previous_range

  private

  def current_presenter
    if current_account.provider_can_use?(:new_notification_system)
      notification_presenter
    else
      messages_presenter
    end
  end

  def notification_presenter
    ::Dashboard::NotificationsPresenter.new(current_user.notifications)
  end

  def messages_presenter
    ::Dashboard::MessagesPresenter.new(current_account.received_messages)
  end

  def unread_messages_presenter
    ::Dashboard::UnreadMessagesPresenter.new(current_account.received_messages.not_system)
  end
end

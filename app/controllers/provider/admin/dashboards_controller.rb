# frozen_string_literal: true

class Provider::Admin::DashboardsController < FrontendController
  before_action :ensure_provider_domain
  before_action :quickstarts_flash, only: :show

  activate_menu :dashboard
  layout 'provider'

  helper_method :presenter

  attr_reader :presenter

  def show
    @service    = find_service
    # Would be cool to
    #
    # .scoped(:include => [ :message => [ :sender ]])
    #
    # but 'Cannot eagerly load the polymorphic association :sender'
    @services           = current_user.accessible_services
    @notifications_presenter = notifications_presenter
    @received_messages_presenter = received_messages_presenter
    @presenter = Provider::Admin::DashboardPresenter.new(user: current_user)
  end

  include DashboardTimeRange
  helper_method :current_range, :previous_range, :backend_apis_presenter, :products_presenter

  private

  def notifications_presenter
    ::Dashboard::NotificationsPresenter.new(current_user.notifications)
  end

  def received_messages_presenter
    ::Dashboard::ReceivedMessagesPresenter.new(current_account.received_messages.not_system)
  end

  def quickstarts_flash
    first_login = flash[:first_login]
    flash.delete(:first_login)

    return unless Features::QuickstartsConfig.enabled? && first_login.present?

    flash[:success] = t('.quick_starts_html', link: provider_admin_quickstarts_path).html_safe
  end
end

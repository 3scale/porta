# frozen_string_literal: true

class Provider::Admin::DashboardsController < FrontendController
  include DashboardTimeRange

  before_action :ensure_provider_domain
  before_action :quickstarts_flash, only: :show

  activate_menu :dashboard
  layout 'provider'

  helper_method :presenter, :current_range, :previous_range

  attr_reader :presenter

  def show
    @presenter = Provider::Admin::Dashboards::DashboardPresenter.new(user: current_user)
  end

  private

  def quickstarts_flash
    first_login = flash[:first_login]
    flash.delete(:first_login)

    return unless Features::QuickstartsConfig.enabled? && first_login.present?

    flash[:success] = t('.quick_starts_html', link: provider_admin_quickstarts_path).html_safe
  end
end

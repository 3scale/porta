module Provider::Admin::DashboardsHelper

  # @param name [Symbol]
  # @param params [Hash]
  def dashboard_widget(name, params = {})
    widget = DashboardWidgetPresenter.new(name, params)
    widget.render
  end

  def friendly_service_name(service)
    if service.name =~ /api$/i
      service.name
    else
      service.name + ' API'
    end
  end

  def sign_class(widget)
    widget.percentual_change > 0 ? 'u-plus' : 'u-minus'
  end

  def dashboard_collection_link(singular_name, collection, path, plural = nil, icon_name = nil)
    link_to path, class: 'DashboardNavigation-link' do
      link = ''
      link << icon(icon_name) + ' ' if icon_name
      link << pluralize(number_to_human(collection.size), singular_name, plural)
      link.html_safe
    end
  end

  def dashboard_secondary_collection_link(singular_name, collection, path, plural = nil)
    link = ' ('
    link << dashboard_collection_link(singular_name, collection, path, plural)
    link << ')'
  end

  def dashboard_counter_link(collection, path)
    link_to collection.size, path, class: "DashboardNavigation-link u-notice"
  end

  def show_pending_accounts_on_dashboard?
    current_account.buyers.pending.exists?
  end

  def show_account_plans_on_dashboard?
    current_account.settings.account_plans.allowed? && current_account.settings.account_plans_ui_visible? && current_account.account_plans.not_custom.size > 1
  end

  def show_forum_on_dashboard?
    current_account.forum_enabled? && current_account.forum.topics.any?
  end

  def show_subscriptions_on_dashboard?(service)
    can?(:manage, :service_contracts) && current_account.settings.service_plans.allowed? && current_account.settings.service_plans_ui_visible?
  end

  def show_service_plans_on_dashboard?(service)
    can?(:manage, :service_plans) && service.service_plans.not_custom.size > 1
  end

  def show_end_users_on_dashboard?(service)
    can?(:manage, :end_users) && service.end_users_allowed? && current_account.settings.end_user_plans_ui_visible?
  end
end

# frozen_string_literal: true

module Provider::Admin::DashboardsHelper

  include ApplicationHelper

  # @param name [Symbol]
  # @param params [Hash]
  # @param variables [Hash]
  def dashboard_widget(name, params = {}, variables = {})
    widget = DashboardWidgetPresenter.new(name, params, variables)
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

  def dashboard_navigation_link(link_text, path, options = {})
    link_to path, title: options[:title], class: css_class({
        'DashboardNavigation-link': true,
        'u-notice': options.fetch(:notice, false)
      }) do
        icon_name = options[:icon_name]
        icon_append_name = options[:icon_append_name]
        link_text = link_text.concat " #{icon(icon_append_name)}" if icon_append_name
        link_text.html_safe
    end
  end

  def dashboard_secondary_link(link_text, path, options = {})
    safe_wrap_with_parenthesis(dashboard_navigation_link(link_text, path, options))
  end

  def dashboard_collection_link(singular_name, collection, path, options = {})
    link_text = pluralize(number_to_human(collection.size), singular_name, options.fetch(:plural, nil))
    dashboard_navigation_link(link_text, path, options)
  end

  def dashboard_secondary_collection_link(singular_name, collection, path, options = {})
    safe_wrap_with_parenthesis(dashboard_collection_link(singular_name, collection, path, options))
  end

  def dashboard_apiap_tab_label(html_for, singular_name, collection, options = {})
    label_text = pluralize(number_to_human(collection.size), singular_name, options.fetch(:plural, nil))
    icon_name = options[:icon_name]
    label_class = css_class(
      'DashboardNavigation-link': true,
      'current-tab': options.fetch(:current_tab, false)
    )
    label_tag html_for, class: label_class do
      concat icon(icon_name) if icon_name
      concat ' '
      concat label_text
    end
  end

  def safe_wrap_with_parenthesis(html)
    " (#{h html})".html_safe
  end

  def show_pending_accounts_on_dashboard?
    current_account.buyers.pending.exists?
  end

  def show_account_plans_on_dashboard?
    current_account.settings.account_plans.allowed? && current_account.settings.account_plans_ui_visible? && current_account.account_plans.not_custom.size > 1
  end

  def show_forum_on_dashboard?
    current_account.forum_enabled? && current_account.forum.recent_topics.any?
  end

  def show_subscriptions_on_dashboard?(service)
    can?(:manage, :service_contracts) && current_account.settings.service_plans.allowed? && current_account.settings.service_plans_ui_visible? && current_account.service_plans.not_custom.size > 1
  end

  def show_service_plans_on_dashboard?(service)
    can?(:manage, :service_plans) && service.service_plans.not_custom.size > 1
  end
end

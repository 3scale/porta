# frozen_string_literal: true

module Provider::Admin::DashboardsHelper
  include PlansHelper
  include ApplicationHelper

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

  def dashboard_collection_link(singular_name, collection, path, options = {})
    link_text = pluralize(number_to_human(collection.size), singular_name, options.fetch(:plural, nil))
    dashboard_navigation_link(link_text, path, options)
  end

  def dashboard_secondary_collection_link(singular_name, collection, path, options = {})
    safe_wrap_with_parenthesis(dashboard_collection_link(singular_name, collection, path, options))
  end

  def safe_wrap_with_parenthesis(html)
    " (#{h html})".html_safe
  end

  def show_pending_accounts_on_dashboard?
    current_account.buyers.pending.exists?
  end

  def show_forum_on_dashboard?
    current_account.forum_enabled? && current_account.forum.recent_topics.any?
  end
end

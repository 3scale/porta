# frozen_string_literal: true

class Provider::Admin::Dashboards::AudienceNavigationPresenter
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::NumberHelper
  include ActionView::Helpers::TextHelper

  attr_reader :messages_name, :messages_count

  # Do not remove the following limit. See https://github.com/3scale/porta/pull/4120.
  MESSAGES_QUERY_LIMIT = 100

  def initialize(user)
    @user = user
    @account = user.account

    all_messages = user.account.received_messages
                               .not_system
                               .limit(MESSAGES_QUERY_LIMIT)
    unread_messages = user.account.received_messages
                                  .not_system
                                  .unread
                                  .limit(MESSAGES_QUERY_LIMIT)

    if (count = unread_messages.count) && count.positive?
      @messages_name = :unread_message
    else
      count = all_messages.count
      @messages_name = :message
    end

    @messages_limited = count == MESSAGES_QUERY_LIMIT
    @messages_count = count
  end

  def drafts
    @drafts ||= @account.templates.with_draft
  end

  def messages_limited?
    @messages_limited
  end

  def pending_buyers
    @pending_buyers ||= buyers.pending
  end

  def buyers
    @buyers ||= @account.buyers
                        .not_master # TODO: is this redundant?
  end

  def applications
    @applications ||= @user.accessible_cinstances
  end

  def alerts
    @alerts ||= @account.buyer_alerts.unread
  end

  def link_to(name, path, options = {})
    options[:class] = ['dashboard-navigation-link', options[:class]].compact

    count = options.delete(:count)
    human_count = if count
                    human_count = number_to_human(count)
                    human_count += '+' if options.delete(:limited)
                    human_count
                  end

    link_name = t(name, count:, human_count:)
    super(link_name, path, options)
  end

  def secondary_link_to(name, path, options = {})
    options[:class] = ['dashboard-navigation-secondary-link', options[:class]].compact
    " (#{link_to(name, path, options)})".html_safe # rubocop:disable Rails/OutputSafety
  end

  private

  def t(str, opts)
    I18n.t("provider.admin.dashboards.audience_navigation.#{str}", **opts)
  end
end

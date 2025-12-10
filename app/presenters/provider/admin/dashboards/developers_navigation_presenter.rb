# frozen_string_literal: true

class Provider::Admin::Dashboards::DevelopersNavigationPresenter
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::NumberHelper
  include ActionView::Helpers::TextHelper

  attr_reader :messages_name, :messages_count

  MAX_VISIBLE_MESSAGES = 100

  def initialize(user)
    @user = user
    @account = user.account

    all_messages = user.account.received_messages
                               .not_system

    if (count = all_messages.unread.count) && count.positive?
      @messages_name = :unread_message
      @messages_limited = count > MAX_VISIBLE_MESSAGES
    else
      count = all_messages.count
      @messages_name = :message
    end

    @messages_limited = count > MAX_VISIBLE_MESSAGES
    @messages_count = [count, MAX_VISIBLE_MESSAGES].min
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
    I18n.t("provider.admin.dashboards.developers_navigation.#{str}", **opts)
  end
end

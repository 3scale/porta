# frozen_string_literal: true

module ApplicationsHelper
  # TODO: need to refactor this method, there is no default return value
  def create_application_link_href(account)
    if account.bought_cinstances.size.zero?
      new_admin_buyers_account_application_path(account)
    elsif can?(:admin, :multiple_applications)
      if can?(:see, :multiple_applications)
        new_admin_buyers_account_application_path(account)
      else
        admin_upgrade_notice_path(:multiple_applications)
      end
    end
  end

  def last_traffic(cinstance)
    return unless cinstance.first_daily_traffic_at?

    date = cinstance.first_daily_traffic_at
    title = "#{time_ago_in_words(date)} ago"
    time_tag(date, date.strftime("%B %e, %Y"), title: title)
  end

  def time_tag_with_title(date_or_time, *args)
    options =  args.extract_options!
    title = args.first || I18n.l(date_or_time, :format => :long)
    args << options.reverse_merge!(:title => title)
    time_tag date_or_time.to_date, *args
  end

  def remaining_trial_days(cinstance)
    expiration_date = cinstance.trial_period_expires_at
    expiration_tag = time_tag(expiration_date,
                              distance_of_time_in_words(Time.zone.now, expiration_date),
                              title: l(expiration_date))
    "&ndash; trial expires in #{expiration_tag}".html_safe # rubocop:disable Rails/OutputSafety
  end
end

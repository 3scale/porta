module AccountHelper

  # Render account's legal address using <address> tag.
  def account_address(account, opts = {})
    address_string = [account.org_legaladdress,
                      account.org_legaladdress_cont,
                      account.city,
                      account.state_region,
                      account.country.try!(:name)].reject(&:blank?).join(', ')

    shortened = if opts[:truncate]
                  truncate(address_string, :length => opts[:truncate])
                else
                  address_string
                end

    content_tag(:address, h(shortened), :title => address_string)
  end

  def label_for_customer_type(account)
    if account.provider?
      'Customer type'
    else
      "Which best describes your customers/users?"
    end
  end

  def account_name(account)
    if account
      h(account.org_name)
    else
      content_tag(:span, 'missing', :class => 'missing')
    end
  end

  def parameterized_org_name_of_the_current_account
    current_account.org_name.parameterize if current_account
  end

  def account_states_for_select
    states = %w[approved pending rejected]
    states << 'suspended' if current_account == Account.master
    options = states.map { |state| [state.titleize, state] }
  end

  def account_states_info(account)
    state_info = account.state.humanize
    if account.scheduled_for_deletion?
      "#{state_info} (#{account.deletion_date.to_date.to_s(:long)})"
    else
      state_info
    end
  end

  #TODO: test this helper
  def path_to_personal_details
    if current_account.provider?
      host = current_account.admin_domain + request.port_string
      edit_provider_admin_user_personal_details_url(host: host, protocol: 'https')
    else
      DeveloperPortal::Engine.routes.url_helpers.admin_account_personal_details_url(host: current_account.domain)
    end
  end

  def time_zone_select_for_account(form)
    form.input( :timezone, :label => 'Time Zone', :as => :select,
                :collection => Account::ALLOWED_TIMEZONES.map { |t| [t.to_s, t.name] },
                :hint => "Time zone in which the charts are displayed. Time zones
          whose UTC offset is not whole hours are not supported.
          Please choose a time zone which is closest to yours.")
  end

  def delete_buyer_link(account)
    return if account.scheduled_for_deletion?
    msg = t("buyers.accounts.edit.#{account.provider? ? 'schedule_for_deletion_confirmation' : 'delete_confirmation'}",
            deletion_time_left: distance_of_time_in_words(Account::States::PERIOD_BEFORE_DELETION),
            name: h(account.name),
            deletion_date: Account::States::PERIOD_BEFORE_DELETION.from_now.to_date.to_s(:long))
    alert = t('buyers.accounts.edit.delete.admin_restricted', admin: current_account.first_admin.try(:email))

    url = can?(:destroy, account) ? admin_buyers_account_path(account) : javascript_alert_url(alert)
    delete_link_for(url, confirm: msg)
  end

  def master_on_premises?
    current_account.master_on_premises?
  end

end

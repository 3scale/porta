# frozen_string_literal: true

module Buyers::ApplicationsHelper

  def new_application_form_metadata(provider:, buyer: nil, service: nil, cinstance: nil)
    provider = ProviderDecorator.new(provider)
    {
      'create-application-path': buyer ? admin_buyers_account_applications_path(buyer) : admin_buyers_applications_path,
      'create-application-plan-path': new_admin_service_application_plan_path(':id'),
      'create-service-plan-path': new_admin_service_service_plan_path(':id'),
      'service-subscriptions-path': admin_buyers_account_service_contracts_path(':id'),
      'service-plans-allowed': provider.settings.service_plans.allowed?.to_json,
      product: service && ServiceDecorator.new(service).new_application_data.to_json,
      products: !service && provider.application_products_data.to_json,
      buyer: buyer && BuyerDecorator.new(buyer).new_application_data.to_json,
      buyers: !buyer && provider.application_buyers_data.to_json,
      'defined-fields': provider.application_defined_fields_data.to_json,
      errors: cinstance&.errors.to_json
    }.compact
  end

  def last_traffic(cinstance)
    if cinstance.first_daily_traffic_at?
      date = cinstance.first_daily_traffic_at
      title = time_ago_in_words(date) + ' ago'
      time_tag(date, date.strftime("%B %e, %Y"), :title => title)
    end
  end

  def time_tag_with_title(date_or_time, *args)
    options =  args.extract_options!
    title = args.first || I18n.l(date_or_time, :format => :long)
    args << options.reverse_merge!(:title => title)
    time_tag date_or_time.to_date, *args
  end

  def remaining_trial_days(cinstance)
    expiration_date = cinstance.trial_period_expires_at
    expiration_tag = time_tag(expiration_date, distance_of_time_in_words(Time.zone.now, expiration_date),
                              :title => l(expiration_date))
    "&ndash; trial expires in #{expiration_tag}".html_safe
  end
end

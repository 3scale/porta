# frozen_string_literal: true

module Buyers::ApplicationsHelper

  def new_application_form_metadata(provider, buyer = nil)
    dataset = {
      'create-application-path': admin_buyers_applications_path,
      'create-service-plan-path': admin_service_service_plans_path(':id'),
      'create-application-plan-path': new_admin_service_application_plan_path(':id'),
      'service-plans-allowed': provider.settings.service_plans.allowed?.to_json,
      products: data_products(provider)
    }
    if buyer.present?
      dataset.merge!({
        'create-application-path': admin_buyers_account_applications_path(buyer),
        buyer: buyer_data(buyer)
      })
    end
    dataset
  end

  def data_products(provider)
    provider.accessible_services.map do |service|
      {
        id: service.id,
        name: service.name,
        appPlans: service.plans.select(:id, :name).as_json(root: false),
        servicePlans: service.service_plans.select(:id, :name).as_json(root: false),
        defaultServicePlan: service.default_service_plan.as_json(root: false, only: %i[id name])
      }
    end.to_json
  end

  def buyer_data(buyer)
    {
      id: buyer.id.to_s,
      name: buyer.name,
      contractedProducts: buyer.bought_service_contracts.services.select(:id, :name).as_json(root: false),
      servicePlans: buyer.bought_service_plans.as_json(only: %i[id name], root: false),
      createApplicationPath: admin_buyers_account_applications_path(buyer)
    }.to_json
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

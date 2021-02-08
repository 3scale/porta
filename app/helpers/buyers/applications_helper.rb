# frozen_string_literal: true

module Buyers::ApplicationsHelper

  def new_application_form_metadata(provider:, buyer: nil, service: nil)
    {
      'create-application-path': buyer ? admin_buyers_account_applications_path(buyer) : admin_buyers_applications_path,
      'create-application-plan-path': new_admin_service_application_plan_path(':id'),
      'service-plans-allowed': provider.settings.service_plans.allowed?.to_json,
      product: service && product_data(service).to_json,
      products: !service && data_products(provider).to_json,
      buyer: buyer && buyer_data(buyer).to_json,
      buyers: !buyer && data_buyers.to_json
    }.compact
  end

  def product_data(service)
    service = service.decorate
    {
      id: service.id,
      name: service.name,
      systemName: service.system_name,
      updatedAt: service.updated_at,
      appPlans: service.plans.select(:id, :name).as_json(root: false),
      servicePlans: service.service_plans.select(:id, :name).as_json(root: false),
      defaultServicePlan: service.default_service_plan.as_json(root: false, only: %i[id name])
    }
  end

  def data_products(provider)
    provider.accessible_services
            .order(updated_at: :desc)
            .decorate
            .map do |service|
              product_data(service)
            end
  end

  def buyer_data(buyer)
    buyer = buyer.decorate
    {
      id: buyer.id.to_s,
      name: buyer.name,
      admin: buyer.admin_user_display_name,
      createdAt: buyer.created_at.to_s(:long),
      contractedProducts: contracts(buyer),
      createApplicationPath: admin_buyers_account_applications_path(buyer),
      # canSelectPlan: true # TODO needed?
    }
  end

  def data_buyers
    current_account.buyer_accounts
                   .not_master
                   .order(created_at: :desc)
                   .map do |buyer|
                     buyer_data(buyer)
                   end
  end

  def contracts(buyer)
    buyer.bought_service_contracts.map do |contract|
      hash = contract.service.as_json(only: %i[id name], root: false)
      hash.merge!({ withPlan: contract.plan.as_json(only: %i[id name], root: false) })
    end
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

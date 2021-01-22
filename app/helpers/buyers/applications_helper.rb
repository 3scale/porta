# frozen_string_literal: true

module Buyers::ApplicationsHelper

  def new_application_form_metadata(provider, buyer = nil)
    dataset = {
      'create-service-plan-path': create_service_plan_path,
      'relation-service-and-service-plans': relation_service_and_service_plans(provider), # DELETEME: APPDUX-762
      'relation-plans-services': relation_plans_services(provider), # DELETEME: APPDUX-762
      'create-application-path': admin_buyers_applications_path,
      'service-plans-allowed': provider.settings.service_plans.allowed?,
      services: provider.accessible_services.to_json(only: %i[id name], root: false),
      'application-plans': provider.application_plans.where(issuer: accessible_services)
                                                     .to_json(only: %i[id name issuer_id], root: false)
    }

    if buyer.present?
      dataset.merge!({
        'services-contracted': services_contracted(buyer),
        'service-plan-contracted-for-service': service_plan_contracted_for_service(buyer), # DELETEME: APPDUX-762
        'create-application-path': admin_buyers_account_applications_path(buyer),
        'buyer-id': buyer.id
      })
    end

    dataset
  end

  def services_contracted(buyer)
    buyer.bought_service_contracts.services.pluck(:id).to_json
  end

  # DELETEME: APPDUX-762
  def service_plan_contracted_for_service(buyer)
    buyer.bought_service_contracts.inject({}) do |hash, service_contract|

      service_plan = service_contract.plan
      name = service_plan.name
      name += " (#{service_contract.state})" unless service_contract.live?

      hash[service_plan.service.id] = {id: service_plan.id, name: name}
      hash
    end.to_json
  end

  # DELETEME: APPDUX-762
  def relation_service_and_service_plans(provider)
    provider.accessible_services.inject({}) do |hash, service|
      hash[service.id] = service.service_plans.inject([]) do |array, service_plan|
        array << {id: service_plan.id, name: service_plan.name, default: service_plan.master?}
      end
      hash
    end.to_json
  end

  # DELETEME: APPDUX-762
  def relation_plans_services(provider)
    provider.application_plans.includes(:service).each_with_object({}) do |application_plan, hash|
      hash[application_plan.id] = application_plan.service.id
    end.to_json
  end

  def create_service_plan_path
    admin_service_service_plans_path ':service_id'
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

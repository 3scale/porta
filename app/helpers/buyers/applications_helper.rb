module Buyers::ApplicationsHelper

  def metadata_new_app(buyer, provider)
    "<div id='metadata-form'
      data-services_contracted='#{services_contracted(buyer)}'
      data-service_plan_contracted_for_service='#{service_plan_contracted_for_service(buyer)}'
      data-relation_service_and_service_plans='#{relation_service_and_service_plans(provider)}'
      data-application-plans='#{application_plans_with_services(provider)}'
      data-service-plans-allowed='#{current_account.settings.service_plans.allowed?}'
      data-relation_plans_services= '#{relation_plans_services(provider)}' >".html_safe
  end

  def services_contracted(buyer)
    buyer.bought_service_contracts.services.pluck(:id).to_json
  end

  def service_plan_contracted_for_service(buyer)
    buyer.bought_service_contracts.inject({}) do |hash, service_contract|

      service_plan = service_contract.plan
      name = service_plan.name
      name += " (#{service_contract.state})" unless service_contract.live?

      hash[service_plan.service.id] = {id: service_plan.id, name: name}
      hash
    end.to_json
  end

  def application_plans_with_services(provider)
    provider.application_plans.stock.includes(:service).map do |app_plan|
      {
        id: app_plan.id,
        name: app_plan.name,
        servicePlans: app_plan.service.service_plans.select(:id, :name)
      }
    end.to_json(root: false)
  end

  def service_plans_grouped_collection_with_app_plans(app_plans)
    app_plans.includes(:service).each_with_object({}) do |app_plan, service_plans|
      service_plans[app_plan.name] = app_plan.service.service_plans.pluck(:name, :id)
    end
  end

  def relation_service_and_service_plans(provider)
    provider.accessible_services.inject({}) do |hash, service|
      hash[service.id] = service.service_plans.inject([]) do |array, service_plan|
        array << {id: service_plan.id, name: service_plan.name, default: service_plan.master?}
      end
      hash
    end.to_json
  end

  def relation_plans_services(provider)
    provider.application_plans.includes(:service).each_with_object({}) do |application_plan, hash|
      hash[application_plan.id] = application_plan.service.id
    end.to_json
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

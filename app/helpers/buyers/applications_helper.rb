module Buyers::ApplicationsHelper

  def metadata_new_app(buyer, provider)
    application_plans = application_plans(provider, buyer)
    default_plan_id = default_plan(provider)[:id]
    default_plan = application_plans.find { |p| p[:id] == default_plan_id }

    "<div id='metadata-form'
      data-plans='#{application_plans.to_json}'
      data-default_plan='#{default_plan.to_json}'
      data-user_defined_fields='#{user_defined_fields}'
      data-service-plans-allowed='#{current_account.settings.service_plans.allowed?}'
    >".html_safe
  end

  def user_defined_fields
    @cinstance.defined_fields.map do |f|
      {
        name: f.name,
        hidden: f.hidden,
        required: f.required,
        label: f.label
        # TODO: include input type if possible (text, textarea, etc) inferred by Formtastic
      }
    end.to_json
  end

  def application_plans(provider, buyer)
    service_plans_contracted_for_service = service_plan_contracted_for_service(buyer)
    service_plans_for_service = relation_service_and_service_plans(provider)
    
    provider.application_plans.map do |plan|
      base = {
        id: plan.id,
        name: plan.name,
        serviceName: plan.service.name
      }

      if !current_account.settings.service_plans.allowed?
        base
      end

      service_id = plan.issuer_id
      if service_plan = service_plans_contracted_for_service[service_id]
        base.merge({ contractedServicePlan: service_plan })
      else
        base.merge({ servicePlans: service_plans_for_service[service_id] })
      end
    end
  end

  def default_plan(provider)
    plans = provider.application_plans.stock
    plans.try(:default).first || plans.first
  end

  def service_plan_contracted_for_service(buyer)
    buyer.bought_service_contracts.inject({}) do |hash, service_contract|

      service_plan = service_contract.plan
      name = service_plan.name
      name += " (#{service_contract.state})" unless service_contract.live?

      hash[service_plan.service.id] = {id: service_plan.id, name: name}
      hash
    end
  end

  def relation_service_and_service_plans(provider)
    provider.accessible_services.inject({}) do |hash, service|
      hash[service.id] = service.service_plans.inject([]) do |array, service_plan|
        array << {id: service_plan.id, name: service_plan.name, default: service_plan.master?}
      end
      hash
    end
  end

  # TODO: delete this method?
  def last_traffic(cinstance)
    if cinstance.first_daily_traffic_at?
      date = cinstance.first_daily_traffic_at
      title = time_ago_in_words(date) + ' ago'
      time_tag(date, date.strftime("%B %e, %Y"), :title => title)
    end
  end
  
  # TODO: delete this method?
  def time_tag_with_title(date_or_time, *args)
    options =  args.extract_options!
    title = args.first || I18n.l(date_or_time, :format => :long)
    args << options.reverse_merge!(:title => title)
    time_tag date_or_time.to_date, *args
  end
  
  # TODO: delete this method?
  def remaining_trial_days(cinstance)
    expiration_date = cinstance.trial_period_expires_at
    expiration_tag = time_tag(expiration_date, distance_of_time_in_words(Time.zone.now, expiration_date),
                              :title => l(expiration_date))
    "&ndash; trial expires in #{expiration_tag}".html_safe
  end
end

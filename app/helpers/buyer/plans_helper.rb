module Buyer::PlansHelper
  def set_prototip
    js = ''
    for metric in @service.metrics.top_level
      js << %{new Bubble('metric_#{metric.id}', '#{metric.description}');}
    end

    for feature in @service.features.visible
      js << %{new Bubble('feature_#{feature.id}', '#{feature.description}');}
    end
    js
  end

  def select_box_of_all_plans(owned_plan)
    plans = owned_plan.issuer.published_application_plans.select{|p| p.id != owned_plan.id}
    plans << owned_plan
    plans.collect!{|p| [p.name, p.id.to_s]}
    select_tag 'plans', options_for_select(plans), :id => 'plan-select'
  end

  def plans_as_collection_for(provider)
      provider.published_application_plans.collect{|p| [p.name, p.id.to_s]}
  end

end



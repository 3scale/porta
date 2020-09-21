module Buyer::PlansHelper

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



Given /^pricing rules on plan "([^\"]*)":$/ do |plan_name, table|
  plan = Plan.find_by_name!(plan_name)

  table.hashes.each do |hash|
    metric = plan.provider_account.default_service.metrics.find_by_system_name!(hash['Metric'])

    plan.pricing_rules.where(:metric => metric).destroy_all

    plan.pricing_rules.create!(:metric => metric, :cost_per_unit => hash['Cost per unit'],
                               :min => hash['Min'],
                               :max => hash['Max'] == 'infinity' ? nil : hash['Max'].to_i)
  end
end

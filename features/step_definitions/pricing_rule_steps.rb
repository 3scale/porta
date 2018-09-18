Given /^a pricing rule on plan "([^"]*)" with metric "([^"]*)", cost per unit ([0-9\.]+) and interval from (\d+) to (infinity|\d+)$/ do |plan_name, metric_name, cost_per_unit, min, max|
  plan = Plan.find_by_name!(plan_name)
  metric = plan.provider_account.default_service.metrics.find_by_system_name!(metric_name)

  plan.pricing_rules.create!(:metric => metric, :cost_per_unit => cost_per_unit,
                             :min => min, :max => max == 'infinity' ? nil : max)
end

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

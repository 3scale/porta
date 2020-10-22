# frozen_string_literal: true

Given "a pricing rule on plan {string} with metric {string}, cost per unit {int} and interval from {int} to {}" do |plan_name, metric_name, cost_per_unit, min, max|
  plan = Plan.find_by!(name: plan_name)
  metric = plan.provider_account.default_service.metrics.find_by!(system_name: metric_name)

  plan.pricing_rules.create!(metric: metric,
                             cost_per_unit: cost_per_unit,
                             min: min,
                             max: max == 'infinity' ? nil : max.to_i)
end

Given "pricing rules on plan {string}:" do |plan_name, table|
  plan = Plan.find_by!(name: plan_name)

  table.hashes.each do |hash|
    metric = plan.provider_account.default_service.metrics.find_by!(system_name: hash['Metric'])

    plan.pricing_rules.where(metric: metric).destroy_all

    plan.pricing_rules.create!(metric: metric,
                               cost_per_unit: hash['Cost per unit'],
                               min: hash['Min'],
                               max: hash['Max'] == 'infinity' ? nil : hash['Max'].to_i)
  end
end

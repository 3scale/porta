# frozen_string_literal: true

# Example:
#
# Given a product "My API"
# And the following application plans:
#   | Product | Name    | Cost per month | Setup fee | Requires approval | State     | Default |
#   | My API  | Free    |                |           | true              | Published |         |
#   | My API  | Premium |                |        10 |                   | Hidden    | True    |
Given "the following {plan_type} plan(s):" do |plan_type, table|
  transform_plans_table(plan_type, table).hashes.each do |row|
    FactoryBot.create(plan_type, row)
  end
end

Given "{plan} is published" do |plan|
  plan.publish! unless plan.published?
end

Given "{plan} is hidden" do |plan|
  plan.hide! unless plan.hidden?
end

Given "{plan} has {int} contract(s)" do |plan, amount|
  FactoryBot.create_list(:buyer_account, amount, provider_account: @provider).each do |buyer|
    buyer.buy!(plan)
  end
end

Given "{plan} has been deleted" do |plan|
  plan.destroy
end

# TODO: make a general, attribute setting step for plan?
Given "{plan} has a trial period of {int} days" do |plan, days|
  plan.update!(trial_period_days: days)
end

Given "{plan} has a monthly fee of {int}" do |plan, fee|
  plan.update!(cost_per_month: fee)
end

Given "{plan} has a setup free of {int}" do |plan, fee|
  plan.update!(setup_fee: fee)
end
# END_TODO

Given "{application_plan} has no usage limits for metric {string}" do |plan, metric|
  plan.issuer
      .metrics
      .find_by!(friendly_name: metric)
      .usage_limits
      .delete_all
end

Given "{application_plan} has defined the following usage limit(s):" do |plan, table|
  transform_usage_limits_table(table, plan)
  table.hashes.each do |row|
    FactoryBot.create(:usage_limit, plan: plan,
                                    metric: row[:metric],
                                    period: row[:period],
                                    value: row[:max_value])
  end
end

Given "{application_plan} has defined all usage limits for {string}" do |plan, metric|
  metric = plan.issuer.metrics.find_by!(friendly_name: metric)

  UsageLimit::PERIODS.each do |period|
    FactoryBot.create(:usage_limit, plan: plan,
                                    period: period,
                                    value: 1,
                                    metric: metric)
  end
end

# Given application plan "Free" has the following features:
#   | Name          | Description | Enabled? |
#   | Some Feature  |             | True     |
#   | Other Feature | Bananas     |          |
Given "{plan} has the following features:" do |plan, table|
  issuer = plan.issuer
  all_features = issuer.features
  plan_features = plan.features

  transform_plan_features_table(table)
  table.hashes.each do |row|
    # TODO: use a factory FactoryBot.create(:feature)
    enabled = row.delete('enabled')
    feature = all_features.find_or_create_by(scope: plan.class.to_s, featurable: issuer, **row)
    plan_features << feature if enabled
  end
end

Given "{plan} does not have any features" do |plan|
  plan.issuer.features.with_object_scope(plan).destroy_all
end

When('they {enable} feature {string}') do |enable, feature_name|
  find('table#features tbody tr', text: feature_name)
    .find(".operations i.#{enable ? 'excluded' : 'included'}")
    .click
end

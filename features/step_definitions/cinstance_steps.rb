# frozen_string_literal: true

Given "{provider} requires cinstances to be approved before use" do |provider|
  provider.application_plans.each do |plan|
    plan.approval_required = true
    plan.save!
  end
end

Then "{buyer} should have {int} cinstance(s)" do |buyer, number|
  assert_equal number.to_i, buyer.bought_cinstances.count
end

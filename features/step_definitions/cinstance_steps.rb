
Given /^(provider "[^"]*") requires cinstances to be approved before use$/ do |provider|
  provider.application_plans.each do |plan|
    plan.approval_required = true
    plan.save!
  end
end

Then /^(buyer "[^"]*") should have (\d+) cinstances?$/ do |buyer_account, number|
  assert_equal number.to_i, buyer_account.bought_cinstances.count
end

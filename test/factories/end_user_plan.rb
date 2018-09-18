Factory.define(:end_user_plan) do |plan|
  plan.sequence(:name) { |n| "plan-#{n}" }
end

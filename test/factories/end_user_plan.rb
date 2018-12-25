FactoryBot.define do
  factory(:end_user_plan) do
    sequence(:name) { |n| "plan-#{n}" }
  end
end

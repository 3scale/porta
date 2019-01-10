FactoryBot.define do
  factory(:plan_metric) do
    association(:plan, :factory => :application_plan)
    association(:metric)
  end
end

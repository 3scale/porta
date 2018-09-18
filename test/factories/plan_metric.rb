Factory.define(:plan_metric) do |plan_metric|
  plan_metric.association(:plan, :factory => :application_plan)
  plan_metric.association(:metric)
end

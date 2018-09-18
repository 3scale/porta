Factory.define(:invoice) do |invoice|
  invoice.association :buyer_account,  :factory => :simple_buyer
  invoice.association :provider_account,  :factory => :simple_provider
  invoice.period Month.new(Time.zone.now)
end

Factory.define(:line_item) {}
Factory.define(:line_item_plan_cost, class: LineItem::PlanCost) {}
Factory.define(:line_item_variable_cost, class: LineItem::VariableCost) {}

Factory.define(:invoice_counter) do |counter|
  counter.association :provider_account,  factory: :simple_provider
  counter.invoice_prefix Month.new(Time.zone.now).to_param
  counter.invoice_count 0
end

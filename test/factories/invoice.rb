# frozen_string_literal: true

FactoryBot.define do
  factory(:invoice) do
    association :buyer_account,  :factory => :simple_buyer
    association :provider_account,  :factory => :simple_provider
    period { Month.new(Time.zone.now) }

    after(:create) do |invoice|
      invoice.generate_pdf! if %w[finalized paid].include?(invoice.state)
    end
  end

  factory(:line_item)
  factory(:line_item_plan_cost, class: LineItem::PlanCost)
  factory(:line_item_variable_cost, class: LineItem::VariableCost)

  factory(:invoice_counter) do
    association :provider_account,  factory: :simple_provider
    invoice_prefix { Month.new(Time.zone.now).to_param }
    invoice_count { 0 }
  end
end

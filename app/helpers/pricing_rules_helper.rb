module PricingRulesHelper
  def display_pricing_rule_range(pricing_rule)
    if pricing_rule.max
      "#{pricing_rule.min} - #{pricing_rule.max} #{pricing_rule.metric.unit}"
    else
      "more than #{pricing_rule.min - 1} #{pricing_rule.metric.unit}"
    end
  end
end

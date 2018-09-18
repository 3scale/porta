module PricingRulesRepresenter
  include ThreeScale::JSONRepresenter

  wraps_collection :pricing_rules

  items extend: PricingRuleRepresenter
end

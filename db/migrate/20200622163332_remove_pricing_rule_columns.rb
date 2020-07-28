# frozen_string_literal: true

class RemovePricingRuleColumns < ActiveRecord::Migration[5.0]
  def up
    safety_assured { remove_column(:pricing_rules, :plan_type) }
  end
end

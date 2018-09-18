module Liquid
  module Drops
    class PricingRule < Drops::Base
      allowed_name :pricing_rule

      example "Using pricing rule drop in liquid.", %{
        <h1>Pricing rule</h1>
        <div>Min value {{ pricing_rule.min }}</div>
        <div>Max value {{ pricing_rule.max }}</div>
        <div>Cost per unit {{ pricing_rule.cost_per_unit }}</div>
      }

      privately_include do
        include ThreeScale::MoneyHelper
        include ActionView::Helpers::NumberHelper
      end

      def initialize(rule)
        @rule = rule
      end

      desc "Returns the cost per unit of the pricing rule."
      def cost_per_unit
        price_tag(@rule.cost_per_unit_as_money, :precision => 4)
      end

      desc "Returns the minimum value of the pricing rule."
      def min
        @rule.min
      end

      desc "Returns the maximum value of the pricing rule."
      def max
        @rule.max || "&#8734;".html_safe
      end

      desc "Returns plan of pricing rule."
      def plan
        Drops::Plan.new(@rule.plan)
      end
    end
  end
end

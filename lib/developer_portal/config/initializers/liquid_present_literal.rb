# In Liquid 5.x, we use a unique marker object and patch Condition to handle comparisons with 'present' literal:
#    {% if current_account.applications.first == present %}
# This is required because existing templates use it
# Previously, this feature was added like this:
#    Liquid::Expression::LITERALS['present'] = :present?
# but in the latest Liquid this constant hash is frozen

module LiquidPresentLiteral
  # Unique marker object to identify 'present' in expressions
  PRESENT = Object.new.freeze

  # Patch Expression.parse to return our marker for 'present'
  module ExpressionPatch
    def parse(markup)
      return LiquidPresentLiteral::PRESENT if markup.to_s == 'present'
      super
    end
  end

  # Patch Condition to handle PRESENT marker comparisons
  module ConditionPatch
    def interpret_condition(left, right, op, context)
      left_value  = Liquid::Utils.to_liquid_value(context.evaluate(left))
      right_value = Liquid::Utils.to_liquid_value(context.evaluate(right))

      # Check if comparing with 'present'
      if (right_value == LiquidPresentLiteral::PRESENT || left_value == LiquidPresentLiteral::PRESENT) && op == '=='
        value = right_value == LiquidPresentLiteral::PRESENT ? left_value : right_value
        # A value is present if it's not nil, not empty string, and not an empty array/hash
        return !value.nil? && value != '' && (!value.respond_to?(:empty?) || !value.empty?)
      end

      super
    end
  end
end

Liquid::Expression.singleton_class.prepend(LiquidPresentLiteral::ExpressionPatch)
Liquid::Condition.prepend(LiquidPresentLiteral::ConditionPatch)

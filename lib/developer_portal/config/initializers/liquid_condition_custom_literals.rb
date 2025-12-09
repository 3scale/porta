# This module adds a 'present' literal to the liquid conditions, so that
# expressions such as the following can be used:
#    {% if current_account.applications.first == present %}
# This is required because existing templates use it
# Previously, this feature was added like this:
#    Liquid::Expression::LITERALS['present'] = :present?
# but in the latest Liquid this constant hash is frozen

module LiquidConditionCustomLiterals
  CUSTOM_LITERALS = {
    'present' => Liquid::Condition::MethodLiteral.new(:present?, '').freeze
  }.freeze

  def parse_expression(parse_context, markup)
    CUSTOM_LITERALS[markup] || super
  end
end

Liquid::Condition.singleton_class.prepend(LiquidConditionCustomLiterals)

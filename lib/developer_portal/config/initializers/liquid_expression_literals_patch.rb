# This module adds a 'present' literal to the liquid expressions, so that
# expressions such as the following can be used:
#    {% if current_account.applications.first == present %}
# This is required because existing templates use it
# Previously, this feature was added like this:
#    Liquid::Expression::LITERALS['present'] = :present?
# but in the latest Liquid this constant hash is frozen

module LiquidExpressionCustomLiterals
  CUSTOM_LITERALS = {
    'present' => :present?
  }.freeze

  def parse(markup)
    str = markup.to_s
    return CUSTOM_LITERALS[str] if CUSTOM_LITERALS.key?(str)

    super
  end
end

Liquid::Expression.singleton_class.prepend(LiquidExpressionCustomLiterals)

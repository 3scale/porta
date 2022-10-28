# frozen_string_literal: true

# Adds input followed by currency string and displays only two
# decimals of the value.
#
# FIXME: if the price has more than 2 decimals than they are cut
# on display - clicking save then damages the data!
#
class PriceInput < Formtastic::Inputs::NumberInput
  def to_html
    input_wrapping do
      label_html <<
      builder.number_field(method, input_html_options) <<
      ' ' + currency.to_s
    end
  end

  def input_html_options
    super.merge({ value: value, min: 0, step: 0.01 })
  end

  private

  def value
    options[:value] || template.format_cost(@object.send(method))
  end

  def currency
    options[:currency] || @object.try!(:currency) || Account::DEFAULT_CURRENCY
  end
end

# Please use this instead of price_tag as has_money will be removed.
#
module CostHelper

  def format_cost(value)
    cost = value.to_s

    # HACK: very lame way to add trailing zero so that the number
    # looks more like money, for example: 42.0 => 42.00
    cost += '0' if cost =~ /\.\d$/
    cost
  end

end

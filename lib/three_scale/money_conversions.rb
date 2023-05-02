# frozen_string_literal: true

module ThreeScale
  module MoneyConversions
    def to_has_money(currency, date = nil)
      ThreeScale::Money.new(self, currency, date)
    end
  end

  # Enhance numeric types with +to_has_money+ method.
  Numeric.send(:include, MoneyConversions)

  # Enhance String with +to_has_money+ method.
  class ::String
    def to_has_money(currency, date = nil)
      to_d.to_has_money(currency, date)
    end
  end
end

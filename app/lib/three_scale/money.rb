module ThreeScale

  # This class represents some amount of money with currency. It behaves more or
  #   less like Numeric type, so it supports basic arithemtic operations,
  #   comparisons, and so on. All operators convert both money objects to the
  #   same currency (the currency of the first operand) before performing
  #   calculations. The conversion is done using exchange rates that are fetched
  #   from external service. A money object can also have a date specified,
  #   which is then used by currency conversion to use historic rates from that
  #   date.
  class Money
    include Comparable

    attr_reader :amount
    attr_reader :currency
    attr_reader :date

    def initialize(amount, currency, date = nil)
      @amount = amount
      @currency = currency
      @date = date
    end

    def == (other)
      other.respond_to?(:to_has_money) &&
        (amount == other.to_has_money(currency, date).amount)
    end

    def equal?(other)
      other.is_a?(self.class) &&
        amount == other.amount &&
        currency == other.currency &&
        date == other.date
    end

    def <=> (other)
      amount <=> other.to_has_money(currency, date).amount
    end

    def -@
      self.class.new(-amount, currency, date)
    end

    def + (other)
      self.class.new(amount + other.to_has_money(currency, date).amount, currency, date)
    end

    def - (other)
      self.class.new(amount - other.to_has_money(currency, date).amount, currency, date)
    end

    def * (number)
      self.class.new(amount * number, currency, date)
    end

    def / (number)
      self.class.new(amount / number, currency, date)
    end

    def coerce(other)
      [ other, amount ]
    end

    delegate :zero?, :nonzero?, :positive?, :negative?, to: :amount

    def round(*args)
      self.class.new(amount.round(*args), currency, date)
    end

    # Exchange this money into another currency. If the money object has +date+
    # specified, the exchange rates from that date will be used.
    #
    # == Arguments
    # +target_currency+:: currency to convert the money to. Should be string
    #   with ISO 4217 currency code (EUR, GPB, JPY, ...)
    def in(target_currency, target_date = nil)
      if currency == target_currency
        self.dup
      else
        date = target_date || self.date

        self.class.new(
          self.class.exchange(
            amount, :from => currency, :to => target_currency, :on => date),
          target_currency, date)
      end
    end

    class << self
      delegate :exchange, to: :exchange_service

      attr_accessor :exchange_service
    end

    # Conversion of money to money is actualy currency conversion.
    alias to_has_money in

    delegate :to_f, to: :amount

    delegate :to_s, to: :amount

    def inspect
      output = "#{self.class}(#{currency} #{amount.to_f}"
      output << ", on #{date}" if date
      output << ')'
      output
    end

    # Return the amount in fractional unit of current currency
    # (cents for dollars, euros and other, pence for british pounds, etc...)
    #
    # This method makes this class quack like Money from money gem thus making
    # it compatible with ActiveMerchant.
    def cents
      (amount * 100).to_i
    end

    module Conversions
      def to_has_money(currency, date = nil)
        ThreeScale::Money.new(self, currency, date)
      end
    end

    # Enhance numeric types with +to_has_money+ method.
    Numeric.send(:include, Conversions)

    # Enhance String with +to_has_money+ method.
    class ::String
      def to_has_money(currency, date = nil)
        to_d.to_has_money(currency, date)
      end
    end
  end
end

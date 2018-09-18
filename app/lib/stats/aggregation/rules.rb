module Stats
  module Aggregation
    # Collection of aggregation rules.
    class Rules
      include Enumerable

      def add(*args, &block)
        add_rule(Rule.new(*args, &block))
      end

      def add_rule(rule)
        @rules ||= []
        @rules << rule
      end

      def aggregate(data)
        @rules.each { |rule| rule.aggregate(data) }
      end

      delegate :each, :to => :@rules
    end
  end
end

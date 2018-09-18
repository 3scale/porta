module Liquid
  module Drops
    class UsageLimit < Drops::Base
      allowed_name :usage_limit

      drop_example "Using usage limit drop in liquid.", %{
        You cannot do more than {{ limit.value }} {{ limit.metric.unit }}s per {{ limit.period }}
      }
      def initialize(usage_limit)
        @usage_limit = usage_limit
      end

      desc "Returns the period of the usage limit."
      def period
        @usage_limit.period.to_s
      end

      desc "Usually `hits` but can be any custom method."
      def metric
        @metric ||= ::Liquid::Drops::Metric.new(@usage_limit.metric)
      end

      desc "Returns the value of the usage limit."
      def value
        @usage_limit.value
      end

      hidden
      deprecated "Returns plan drop instead."
      def plan
        @usage_limit.plan_id
      end
    end
  end
end

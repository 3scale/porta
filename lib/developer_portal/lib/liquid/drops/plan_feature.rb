module Liquid
  module Drops
    class PlanFeature < Drops::Feature
      allowed_name :feature

      def initialize(feature, account_plan)
        @feature = feature
        @account_plan = account_plan
      end

      def enabled?
        @account_plan.includes_feature?(@feature)
      end
    end
  end
end

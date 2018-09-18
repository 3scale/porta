module Liquid
  module Drops
    class AccountPlan < Drops::Plan
      allowed_name :account_plan, :account_plans
      drop_example "Using account plan drop in liquid.", %{
        <p class="notice">The examples for plan drop apply here</p>
      }

      desc "Returns an array of available features."
      def features
        @plan.issuer.features.visible.map do |feature|
          Drops::PlanFeature.new(feature, @plan)
        end
      end

      desc "Returns the setup fee."
      def setup_fee
        if @plan.setup_fee > 0
          price_tag(@plan.setup_fee)
        else
          0
        end
      end

    end
  end
end

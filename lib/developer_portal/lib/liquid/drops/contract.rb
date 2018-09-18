module Liquid
  module Drops
    class Contract < Drops::Model
      allowed_name :contract, :subscription
      deprecated_name :service_contract

      drop_example %{
        Plan of the contract {{ contract.plan.name }}
      }

      def initialize(contract)
        raise 'missing contract' unless contract
        @contract = contract
        super
      end

      hidden
      def contract
        self
      end

      hidden
      def new_record?
        @contract.new_record?
      end

      desc "Returns the id."
      def id
        @contract.id
      end

      desc "Returns true if any change is possible."
      def can_change_plan?
        @contract.can_change_plan?
      end

      desc """
             Returns true if the contract is still in the trial period.

             __Note__: If you change the trial period length of a plan,
             it does not affect existing contracts.
           """
      def trial?
        @contract.try(:trial?)
      end

      def live?
        @contract.live?
      end

      desc """There are three possible states:

        - pending
        - live
        - suspended
      """
      def state
        @contract.state
      end

      desc "Number of days left in the trial period."
      def remaining_trial_period_days
        @contract.remaining_trial_period_days
      end

      desc "Returns the plan of the contract."
      def plan
        plan = @contract.plan
        if plan.is_a?(::AccountPlan)
          Drops::AccountPlan.new(plan)
        else
          Drops::Plan.new(plan)
        end
      end

      desc "Returns name of the allowed action."
      def plan_change_permission_name
        @contract.plan_change_permission_name
      end

      desc "Returns a warning message for the allowed action."
      def plan_change_permission_warning
        @contract.plan_change_permission_warning
      end
    end
  end
end

module Liquid
  module Drops
    class Plan < Drops::Base
      allowed_name :plan, :previous_plan

      privately_include  do
        include ThreeScale::MoneyHelper
        include ActionView::Helpers::NumberHelper
      end

      def initialize(plan, opts = {})
        @plan = plan
        @selected = opts[:selected]
        @bought = opts[:bought]
      end

      #TODO: check tihs, this might work only when drop is initialized from new signup drop
      desc "Returns whether the plan is selected."
      example %(
        {% if plan.selected? %}
          <p>You will signup to {{ plan.name }}</p>
        {% endif %}
      )
      def selected?
        @selected || false
      end

      # TODO: this works only when plan is accessed from new signup drop, no?
      desc "Returns whether the plan is bought."
      example %(
        {% if plan.bought? %}
           <p>You are  on this plan already!</p>
        {% endif %}
      )
      def bought?
        @bought || false
      end

      desc "Returns whether the plan is the same as other."
      example %(
        {% if plan == my_free_plan %}
           <p>These plans are the same.</p>
        {% else %}
           <p>These plans are not the same.</p>
        {% endif %}
      )
      def ==(other)
        @plan == other.instance_variable_get('@plan')
      end

      desc "Returns the visible features of the plan."
      def features
        Drops::Feature.wrap( @plan.features.visible )
      end

      desc "Returns the setup fee of the plan."
      def setup_fee
        price_tag(@plan.setup_fee)
      end

      desc "Returns the name of the plan."
      example %(
        <h1>We offer you a new {{ plan.name }} plan!</h1>
      )
      def name
        @plan.name
      end

      # TODO: add lookup by system name in signup
      desc "Returns the system name of the plan."
      example %(
        {% for plan in available_plans %}
          {% if plan.system_name == 'my_free_plan' %}
            <input type="hidden" name="plans[system_name]" value="{{ plan.system_name }}"/>
            <p>You will buy our only free plan!</p>
          {% endif %}
        {% endfor %}
      )
      def system_name
        @plan.system_name
      end

      desc "Returns the plan ID."
      def id
        @plan.id
      end

      desc "The plan is free if it is not 'paid' (see the 'paid?' method)."
      example %(
        {% if plan.free? %}
           <p>This plan is free of charge.</p>
        {% else %}
           <div>
             <p>Plan costs:</p>
             <div>Setup fee {{ plan.setup_fee }}</div>
             <div>Flat cost {{ plan.flat_cost }}</div>
          </div>
        {% endif %}
      )
      def free?
        @plan.free?
      end

      desc "Returns the number of trial days in a plan."
      example %(
       <p>This plan has a free trial period of {{ plan.trial_period_days }} days.</p>
      )
      def trial_period_days
        @plan.trial_period_days
      end

      desc "The plan is 'paid' when it has a non-zero fixed or setup fee or there are pricing rules present."
      example %(
        {% if plan.paid? %}
           <p>this plan is a paid one.</p>
        {% else %}
           <p>this plan is a free one.</p>
        {% endif %}
      )
      def paid?
        !@plan.free?
      end

      desc "Returns whether the plan requires approval."
      example %(
        {% if plan.approval_required? %}
           <p>This plan requires approval.</p>
        {% endif %}
      )
      def approval_required?
        @plan.approval_required?
      end

      hidden
      def class_name
        @plan.name.tr(' ', '_').strip
      end

      desc 'Returns the monthly fixed fee of the plan. (including currency)'
      def flat_cost
        if @plan.cost_per_month > 0
          price_tag(@plan.cost_per_month)
        else
          0.to_s
        end
      end

      desc 'Returns the monthly fixed fee of the plan.'
      def cost
        @plan.cost_per_month
      end
    end
  end
end

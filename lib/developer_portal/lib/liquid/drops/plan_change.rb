module Liquid
  module Drops
    class PlanChange < Drops::Base
      info 'An attempt of plan change. It is used in plan upgrade workflow ' \
      'when developer does not have credit card details filled in ' \
       'and wants to upgrade to a paid plan'

      drop_example <<-EXAMPLE
        <div class="row">
          <div class="col-md-9">
            {% if plan_changes.size > 0 %}
            <p>
              You have begun to change plans of the following applications. <br>
              Please review.
            </p>
            <table class="table panel panel-default" id="applications">
              <thead class="panel-heading">
              <tr>
                <th>Name</th>
                <th>Chosen plan</th>
                <th>Accept</th>
                <th>Reject</th>
              </tr>
              </thead>
              <tbody class="panel-body">
              {% for change in plan_changes %}
              <tr class="{% cycle 'applications': 'odd', 'even' %}" id="application_{{ change.contract_id }}">
                <td>
                  {{ change.contract_name }}
                </td>
                <td>
                  From <strong>{{ change.plan_name }}</strong> to <strong>{{ change.new_plan_name }}</strong>
                </td>
                <td>
                  {{ 'Confirm' | update_button: change.confirm_path , class: 'plan-change-button' }}
                </td>
                <td>
                  {{ 'Cancel' | delete_button: change.cancel_path , class: 'plan-change-button' }}
                </td>
              </tr>
              {% endfor %}
              </tbody>

            </table>
            {% else %}
            <p>
              You have no changes in your application plans.
              {{ 'Go back to applications' | link_to: urls.applications }}
            </p>
            {% endif %}
          </div>
        </div>
      EXAMPLE

      allowed_names :plan_change, :plan_changes

      # Returns a new drop to reflect plan changes on new credit card workflow
      #
      # @param [Cinstance] contract
      # @param [ApplicationPlan] plan
      # @return [Liquid::Drops::PlanChange]
      def initialize(contract, plan)
        @contract = Liquid::Drops::Application.new(contract)
        @plan = Liquid::Drops::ApplicationPlan.new(plan)
        @previous_plan = Liquid::Drops::ApplicationPlan.new(contract.plan)
      end

      desc 'Returns the contract on which the changes will apply.'
      attr_reader :contract

      desc 'Returns the chosen plan.'
      attr_reader :plan

      desc 'Returns the current plan.'
      attr_reader :previous_plan

      desc 'Returns the url to confirm the change. The request method must be POST'
      def confirm_path
        cms_url_helpers.admin_contract_path(@contract.id, plan_id: @plan.id)
      end

      desc 'Returns the url to cancel the change. The request method must be DELETE'
      def cancel_path
        admin_account_plan_change_path(@contract.id)
      end
    end
  end
end

require_dependency 'stats/client'

module Finance
  # Mixin for Cinstance to get the variable costs calculations.
  module VariableCost

    # Bills variable costs for the intersection of "period" and
    # variable_cost_paid_until.
    # - variable costs are billed for complete days.
    # - variable_cost_paid_until marks the exact time of paid variable costs.
    # - intersection bills from the beginning of the first day till the end of the last day
    def bill_for_variable(period, invoice, plan_to_bill = self.plan)
      # TODO: this makes the bill_for method dependent on Time.zone.now
      # so it should be handled differently
      #
      return false if trial?

      transaction do

        if should_bill_variable_cost?(period)
          intersection = intersect_with_unpaid_period(period, variable_cost_paid_until)
          # intersect_with_unpaid_period returns the intersection in
          # time, but it rounds from beginning of day of the first day
          # till end of the day of last day

          bill_variable_fee_for(intersection, invoice, plan_to_bill)

          self.variable_cost_paid_until = period.end
        else
          Rails.logger.info("Skipping contract #{self.id} - already paid until #{variable_cost_paid_until}")
        end

        # no validation because our DB has broken data
        # TODO: cleanup DB and add validations
        if invoice.used?
          self.save(:validate => false)
          true
        else
          false
        end
      end
    end

    # Return the variable cost for the given period.
    #
    # == Arguments
    #
    #   +period+ - Something that quacks like a range of Time-like objects.
    #
    # == Returns
    #
    # a hash of {metric => cost}, where +metric+ is a Metric instance and cost is a number.
    #
    # == TODO
    #
    # period.end is ignored currently, and it is silently assumed that period.begin is the
    # beginning of the month. Support also other periods.
    #
    # TODO: refactor
    def calculate_variable_cost(period, plan_to_bill = self.plan)
      data = Stats::Client.new(self)
      values = {}

      costs = plan_to_bill.pricing_rules.inject({}) do |memo, pricing_rule|
        metric = pricing_rule.metric

        values[metric] ||= data.total(:period   => period,
                                      :timezone => provider_account.timezone,
                                      :metric   => metric)

        memo[metric] ||= 0
        memo[metric] += pricing_rule.cost_for_value(values[metric])
        memo
      end
      [ values, costs ]
    end

    # Using `read_attribute` because the getter method is overloaded
    def never_billed_variable_cost?
      self[:variable_cost_paid_until].blank?
    end

    def should_bill_variable_cost?(period)
      never_billed_variable_cost? || variable_cost_paid_until.to_date < period.end
    end

    protected

    def bill_variable_fee_for(period, invoice, plan_to_bill)
      quantity, variable_cost = calculate_variable_cost(period, plan_to_bill)
      variable_cost = variable_cost.select { |metric,cost|  cost.nonzero? }.sort_by { |m,cost| -cost }

      variable_cost.each do |metric,cost|
        Finance::BackgroundBilling.new(invoice).create_line_item!(
          {
            name: metric.friendly_name,
            cost: cost,
            description: period.to_time_range.to_s,
            quantity: quantity[metric],
            contract: self,
            plan_id: plan_to_bill.id,
            metric_id: metric.id,
            type: LineItem::VariableCost
          }
        )
      end
    end
  end
end

# frozen_string_literal: true

class Finance::PrepaidBillingStrategy < Finance::BillingStrategy
  class BadPeriodError < StandardError
    include Bugsnag::MetaData

    attr_reader :period, :previous_period, :contract
    delegate :accepted_at, :trial_period_expires_at, :created_at, :plan_id, :old_plan_id, to: :contract
    delegate :end, :begin, to: :period, prefix: true
    delegate :end, :begin, to: :previous_period, prefix: true

    def initialize(contract, period, previous_period)
      @contract = contract
      @period = period
      @previous_period = previous_period

      self.bugsnag_meta_data = {
        contract: {
          id: contract.id,
          paid_until: contract['paid_until'],
          accepted_at: accepted_at,
          trial_period_expires_at: trial_period_expires_at,
          created_at: created_at,
          plan_id: plan_id,
          old_plan_id: old_plan_id
        },
        period: {
          self: period,
          begin: period_begin,
          end: period_end
        },
        previous_period: {
          self: previous_period,
          begin: previous_period_begin,
          end: previous_period_end
        }
      }
    end

  end

  def daily(options = {})
    now = options[:now].presence || Time.now.utc
    bill_and_charge_each(options) do |buyer|
      Rails.logger.info("Started to bill and charge of #{buyer.name} at #{now}")
      bill_expired_trials(buyer, now)

      only_on_days(now, 1) do
        bill_fixed_costs(buyer, now)
        bill_variable_costs(buyer, now - 1.month)
      end

      finalize_invoices_of(buyer, now)
      issue_invoices_of(buyer, now)

      charge_invoices(buyer, now)
    end

    notify_billing_finished(now) unless options[:skip_notifications] # In Sidekiq, notifications are triggered by the callback of the jobs batch
  end

  def name
    'prepaid'
  end

  def description
    %q{In prepaid mode, all fixed fees and setup fees are
       billed immediately at the beginning of the month or
       at the beginning of any pro-rated billing period.
       Variable costs are always calculated at the end
       of the month.
    }
  end

  # Differs from Postpaid #bill_variable_costs just by the invoice
  # that is used to bill on: here it is the following month.
  #
  def bill_variable_costs(buyer, now = Time.now.utc)
    month = Month.new(now)

    info("Billing variable cost of #{buyer.org_name} at #{now}", buyer)
    buyer.billable_contracts.find_each(batch_size: 100) do |contract|
      invoice = invoice_for(buyer, now + 1.month)
      contract.bill_for_variable(month, invoice)
    end
  end

  # Billing plan change on prepaid cases:
  # 2) This behaviour was already there.
  #
  # 1) If the contract has never been invoiced:
  # Meaning the plan change is happening the same day as the creation of the contract
  # We can refund safely and we will have proper line items in the same invoice:
  #
  # Description             | Cost
  # ----------------------- | -----
  # Setup fee Plan A        |   200
  # Refund Plan A           |  -200
  # Upgrade Plan A to Plan B|   100
  # Total                   |   100
  #
  # 2) If the contract has already been invoiced:
  # Meaning the plan change is happening another day than the creation of the contract.
  # Billing has run already (paid_until is already set) and an invoice was issued.
  # We cannot refund safely as we would end up with the second invoice having negative total on downgrade.
  # So what we do is only add a line item if it is an upgrade and not a downgrade of plan.
  #
  # We will have two invoices issued on different dates (it is prepaid):
  #
  #
  # Description             | Cost
  # ----------------------- | -----
  # Setup fee Plan A        |   200
  # Total                   |   200
  #
  #
  # Description             | Cost
  # ----------------------- | -----
  # Upgrade Plan A to Plan B|   100
  # Total                   |   100
  def bill_plan_change(contract, period)
    if contract.not_billed_yet?
      bill_plan_change_for_unbilled_contract(contract, period)
    else
      bill_plan_change_for_billed_contract(contract, period)
    end
  end

  private

  def bill_plan_change_for_billed_contract(contract, period)
    plan = contract.plan
    old_plan = contract.old_plan
    difference = plan.cost_for_period(period) - old_plan.cost_for_period(period)

    # Plan change produces a negative cost, do not bill!
    if difference > 0
      upgrade_on_plan_change(contract, old_plan, plan, period)
    else
      info("Not billing anything for plan change, cost variation is negative” ('#{old_plan.name}' to '#{plan.name}')")
    end
  end

  # When the plan change happens before billing passes, i.e. the same day of the creation of the contract
  # We should be able to add all the entries
  # See https://issues.jboss.org/browse/THREESCALE-436
  def bill_plan_change_for_unbilled_contract(contract, period)
    # We bill the old plan for the previous period
    previous_period = TimeRange.new(contract.paid_until.utc, period.end.utc)
    plan = contract.plan
    old_plan = contract.old_plan
    old_plan_name = old_plan.name
    plan_name = plan.name

    add_plan_cost(:bill, contract, old_plan, previous_period)
    info("Plan change occurring but billing was not done yet from ('#{old_plan_name}' to '#{plan_name}')")

    # We refund the old plan for the current period and upgrade the new plan
    upgrade_on_plan_change(contract, old_plan, plan, period)
  rescue Plan::PeriodRangeCalculationError
    # Something bad happens calculating the cost
    System::ErrorReporting.report_error(BadPeriodError.new(contract, period, previous_period))
    error("Plan change occurring but an error occurred billing the period #{previous_period} for ('#{old_plan_name}' to '#{plan_name}')")
    # We still bill on upgrade only
    bill_plan_change_for_billed_contract(contract, period)
  end

  def invoices_to_finalize_of(buyer, now)
    provider.buyer_invoices.by_buyer(buyer).opened
  end

  def upgrade_on_plan_change(contract, old_plan, plan, period)
    add_plan_cost(:refund, contract, old_plan, period)

    cost_for_period = plan.cost_for_period(period)
    return unless cost_for_period.positive?
    description = "#{contract.class.model_name.human} upgrade ('#{old_plan.name}' to '#{plan.name}')"
    add_cost(contract, description, period.to_s, cost_for_period)
  end
end

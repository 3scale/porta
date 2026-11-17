# frozen_string_literal: true

# A facade over the provider's account plans that exposes AccountPlan#approval_required as the
# account_approval_required setting. It can be changed only while the provider has a single stock (non-custom)
# account plan; while there are several it is locked and shows the default plan's flag (nil without a default).
# The plans are loaded once per instance; Settings#reload builds a new one.
class Settings::PlanAccountApprovalRequiredFacade
  def initialize(settings)
    @settings = settings
  end

  def editable?
    stock_plans.one?
  end

  def locked?
    stock_plans.many?
  end

  # The single stock plan's flag; when locked, the default plan's
  def value
    (single_plan || @settings.provider.default_account_plan)&.approval_required
  end

  # Validates only approval_required, importing its errors into the settings, and saves without the plan's other
  # validations, so an unrelated invalid plan attribute doesn't block it
  def update(value)
    return true unless editable?

    plan = single_plan
    plan.approval_required = value
    plan.validate
    plan_errors = plan.errors.where(:approval_required)
    plan_errors.each { @settings.errors.import(_1, attribute: :account_approval_required) }
    plan_errors.empty? && plan.save!(validate: false)
  end

  private

  def single_plan
    stock_plans.first if editable?
  end

  # At most two plans, enough to tell one from several; no query when the account plans are already loaded
  def stock_plans
    @stock_plans ||= begin
      plans = @settings.provider.account_plans
      plans.loaded? ? plans.select { _1.persisted? && _1.original_id.zero? }.first(2) : plans.not_custom.limit(2).to_a
    end
  end
end

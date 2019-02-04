
class Contract < ApplicationRecord
  # Need to define table_name before audited because of
  # https://github.com/collectiveidea/audited/blob/f03c5b5d1717f2ebec64032d269316dc74476056/lib/audited/auditor.rb#L305-L311
  self.table_name = 'cinstances'

  audited :allow_mass_assignment => true
  include ::ThreeScale::MethodTracing

  # FIXME: This class should be an abstract class I think, but doing so makes plenty of tests fail
  # self.abstract_class = true

  include States
  include Billing
  include Trial

  include Finance::FixedFee
  include Finance::SetupFee
  include Finance::NoVariableCost
  include Logic::PlanChanges::Contract

  after_destroy :destroy_customized_plan
  after_commit :notify_plan_changed

  belongs_to :plan, counter_cache: true
  validate   :correct_plan_subclass?
  # this breaks nested saving of records, when validating there is no user_account yet, its new record
  # validates_presence_of :user_account

  validates :description, :redirect_url, :extra_fields,
            length: { maximum: 65535 }
  validates :provider_public_key, :state, :application_id,
            :name, :type, :create_origin,
            length: { maximum: 255 }
  validates :user_key, length: { maximum: 256 }

  # TODO: rename to buyer_account and remove alias
  belongs_to :user_account, class_name: 'Account', autosave: false

  alias buyer_account user_account
  alias buyer         user_account
  alias account       user_account

  delegate :provider_account, to: :plan, allow_nil: true
  delegate :id, to: :provider_account, allow_nil: true, prefix: true
  delegate :id, to: :old_plan, prefix: true, allow_nil: true

  # TODO: remove with Rails 3
  attr_reader :old_plan, :accepted_on_create

  attr_protected :plan_id, :state, :provider_public_key, :paid_until, :trial_period_expires_at, :setup_fee, :type, :variable_cost_paid_until, :application_id, :user_key, :user_account_id, :tenant_id, :audit_ids


  # TODO: unit test this scope
  def self.provided_by(account)
    where.has do
      plan_id.in(Plan.provided_by(account).select(:id))
    end
  end

  def self.issued_by(issuer, *ids)
    scope = Plan.issued_by(issuer, *ids).select(:id)
    where.has { plan_id.in( scope ) }
  end

  # Return contracts bought by given account.
  scope :bought_by, lambda { |account|
    where({:user_account_id => account.id})
  }

  scope :with_account, -> { includes([:user_account])}

  scope :by_type, lambda { |contract_type|
    where({ :type => contract_type.to_s })
  }

  # SEARCH SCOPES
  scope :by_plan_id, lambda { |plan_id|
    where(plan_id: plan_id.to_i)
  }

  scope :by_name, lambda { |text|
    # replace start and end of string with % unless already has %
    pattern = text.sub(/(^[^%])/, '%\\1').sub( /([^%]$)/, '\\1%')
    collate = { oracle: 'GENERIC_M_CI', postgres: '"und-x-icu"', mysql: 'UTF8_GENERAL_CI' }.fetch(System::Database.adapter.to_sym)
    where.has { name.op('COLLATE', sql(collate)).matches(pattern)}
  }

  scope :by_account, lambda { |account| where({ :user_account_id => account.id } ) }
  scope :by_account_query, lambda { |query| where( { :user_account_id => Account.buyers.search_ids(query) } ) }

  def self.by_plan_type(type)

    plans = Plan.unscoped.uniq.joins { pricing_rules.outer }

    plan_type = case type.to_s
                when 'free'
                  plans.where { (cost_per_month == 0) & (setup_fee == 0) & (pricing_rules.id == nil) } # rubocop:disable Style/NumericPredicate,Style/NilComparison
                when 'paid'
                  plans.where { (cost_per_month != 0) | (setup_fee != 0) | (pricing_rules.id != nil) } # rubocop:disable Style/NumericPredicate,Style/NonNilCheck
                else
                  return all
    end

    where{ plan_id.in plan_type.select(:id) }
  end

  delegate :paid?, :to => :plan

  def messenger
    (self.class.name.to_s << "Messenger").constantize
  end

  # TODO: rename service_id field to issuer_id on plan
  def issuer
    plan && plan.issuer
  end

  # TODO: remove this when also Account states (pending, aproved ...) are handled on an
  # account contract.
  #
  def has_lifecycle?
    true
  end

  # TODO: DRY the multiple ways to reach provider_account from
  # contract. The other way is user_account.provider_account
  def provider_account
    plan.try! :provider_account
  end

  def paid_until
    self[:paid_until] || accepted_at || trial_period_expires_at || created_at
  end

  # Using `read_attribute` because the getter method is overloaded
  # Meaning changing plan the same day of the creation of the contract
  # Useful for prepaid billing see PrepaidBillingStrategy#bill_plan_change_safely
  def not_billed_yet?
    self[:paid_until].blank?
  end

  # Returns boolean, indicating if something was billed.
  #
  # Note: trial period is correctly handled thanks to +paid_until+
  # method implementation which takes it into account.
  #
  # TODO: create bill_for! method
  # TODO: logging - the reasons why it billed/skipped billing
  #
  # @param [Month] period
  # @param [Invoice] invoice
  def bill_for(period, invoice)
    # TODO: this makes the bill_for method dependent on Time.zone.now
    # so it should be handled differently
    #
    return false if trial?

    transaction do
      if paid_until.to_date < period.end.to_date
        period = intersect_with_unpaid_period(period, paid_until)

        bill_fixed_fee_for(period, invoice)

        self.paid_until = period.end
      end

      bill_setup_fee_for(period, invoice)

      # no validation because our DB has broken data
      # TODO: cleanup DB and add validations?
      self.save(:validate => false) if invoice.used?

      return invoice.used?
    end
  end

  # this is remaining now here for service_contracts as of now
  # TODO: should be, but breaks a lot of it...
  #  private :plan=

  # Changes plan by calling protected method to change plan
  # passed block is executed in transaction and can abort it
  #
  # TODO: test these change plan methods!
  #
  def change_plan!(new_plan)
    changed = change_plan_internal(new_plan) do
      self.save!
    end

    changed && self.plan
  end

  def change_plan(new_plan)
    changed = change_plan_internal(new_plan) do
      self.save or raise ActiveRecord::Rollback
    end

    changed && self.plan
  end


  # Customize plan this contract is assigned to. If the plan is already customized, it does
  # nothing. If not, if will create a new plan, copying all it's properties from the
  # original plan, then reassigning this contract to this new plan.
  #
  # This method will try to save the customized plan and this contract.
  #
  def customize_plan!(attrs = {})
    unless plan.customized?
      transaction do
        #TODO: this needs testing
        custom = plan.customize(attrs)

        if custom.persisted?
          old_plan = plan
          update_attribute(:plan, custom)
          old_plan.reset_contracts_counter
        end

        custom
      end
    end

    plan.reset_contracts_counter
    plan
  end

  # If the cinstance is on customized plan, revert it back to stock plan.
  def decustomize_plan!
    if plan.customized?
      transaction do
        custom_plan = plan
        self.plan = custom_plan.original
        save!
        custom_plan.destroy
        plan.reset_contracts_counter
      end
    end

    plan
  end

  protected

  def correct_plan_subclass?
    if plan && (not plan.is_a?(Plan))
      errors.add(:plan, 'wrong plan subclass')
    end
  end

  #
  # Internal method which creates transaction
  # and inside transaction changes plan
  # and runs passed block
  #
  # passed block is expected to save the record
  #
  # this method can be (and is) overriden in children
  # to run something after successful trnsaction
  #
  def change_plan_internal(new_plan, &block)
    return if self.plan == new_plan
    raise 'change_plan_internal must be called with a block' unless block_given?

    transaction do



      # workaround - remove with Rails 3
      @old_plan = self.plan

      self.plan = new_plan
      # TODO: change to notify_observers and add old/new params after
      # migration to Rails 3

      res = yield

      new_plan.reset_contracts_counter

      @old_plan.customized? ? @old_plan.destroy : @old_plan.reset_contracts_counter

      res
    end
  end

  add_three_scale_method_tracer :change_plan_internal

  private

  def notify_plan_changed
    if previously_changed?(:plan_id) && @old_plan
      notify_observers(:bill_variable_for_plan_changed, @old_plan)
      notify_observers(:plan_changed)

      if plan.cost_per_month < @old_plan.cost_per_month
        plan.notify_observers(:plan_downgraded, @old_plan, self)
      end

      @old_plan = nil
    end
  end

  def destroy_customized_plan
    plan.destroy if plan.try!(:customized?)
  end

  def accept_on_create
    # RAILS3: not sure if we have to do this fancyness with webhooks
    # accept! if can_accept? and not plan.approval_required? # or service.plan.approval_required?
    return if plan.approval_required? # or service.plan.approval_required?
    # this skips saving the record
    # unfortunately it creates empty transaction
    @accepted_on_create = true
    fire_events!(:accept, false)
  end

  def intersect_with_unpaid_period(period, paid_end)
    if period.is_a?(BillingObserver::RangeForVariableCost)
      period = period.begin..(period.end - 1.second)
    end

    from = [ period.begin.to_date, paid_end ].max.to_date
    to = [ period.end.to_date, from ].max.to_date

    from.to_time..to.to_time.end_of_day
  end

end

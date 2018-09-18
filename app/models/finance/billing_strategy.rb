# frozen_string_literal: true

class Finance::BillingStrategy < ApplicationRecord
  module NonAuditedColumns
    def non_audited_columns
      super - [inheritance_column]
    end
  end

  class << self
    prepend NonAuditedColumns
  end

  audited :allow_mass_assignment => true

  attr_reader :failed_buyers

  CURRENCIES = {
    'USD - American Dollar' => 'USD',
    'EUR - Euro'=> 'EUR',
    'GBP - British Pound' => 'GBP',
    'NZD - New Zealand dollar' => 'NZD',
    'CNY - Chinese Yuan Renminbi' => 'CNY',
    'CAD - Canadian Dollar' => 'CAD',
    'AUD - Australian Dollar' => 'AUD',
    'JPY - Japanese Yen' => 'JPY'
  }

  belongs_to :account
  alias_attribute :provider, :account

  attr_protected :account_id, :tenant_id, :audit_ids

  accepts_nested_attributes_for :account
  validates :currency, inclusion: { :in => CURRENCIES.values }

  # TODO: uncomment when factories are fixed
  # validates_presence_of :account
  validates :numbering_period, presence: true
  validates :numbering_period, inclusion: { :in => %w(monthly yearly).freeze }, length: { maximum: 255 }
  validates :currency, :type, length: { maximum: 255 }

  def self.daily_canaries
    return if canaries.blank?
    daily_async(where("account_id in (?)", canaries))
  end

  def self.daily_rest
    if canaries.blank?
      daily_async(all)
    else
      daily_async(where("account_id not in (?)", canaries))
    end
  end

  def self.daily_async(scope, options = {})
    now = options[:now] || Time.now.utc

    scope.select([:id, :account_id]).includes(:account).find_each do |billing_strategy|
      Finance::BillingService.async_call(billing_strategy.account, now)
    end
  end

  def self.canaries
    ThreeScale.config.billing_canaries || []
  end

  # Supported options
  #
  # :now - time when the billing is happening
  # :only - run billing only for providers with those IDs
  # :exclude - run billing for all providers, but exclude those IDs
  #
  def self.daily(options = {})
    raise 'Options must be a hash' unless options.is_a?(Hash)

    now = options[:now] || Time.now.utc
    skip_notifications = options[:skip_notifications]

    scope = if options.has_key?(:only)
              where("account_id in (?)", options[:only])
            elsif options.has_key?(:exclude)
              where("account_id not in (?)", options[:exclude])
            else
              all
            end

    results = Finance::BillingStrategy::Results.new(now)
    scope.find_each(:batch_size => 5) do |billing_strategy|
      begin
        unless billing_strategy.active?
          next results.skip(billing_strategy)
        end

        results.start(billing_strategy)
        ignoring_find_each_scope { billing_strategy.daily(now: now, buyer_ids: options[:buyer_ids], skip_notifications: skip_notifications) }
        results.success(billing_strategy)
      rescue => e
        results.failure(billing_strategy)
        name = billing_strategy.provider.try!(:name)
        id = billing_strategy.id
        message = "BillingStrategy #{id}(#{name}) failed utterly"

        Rails.logger.error(message)
        airbrake(:error_message => message,
                 :error_class => 'BillingError',
                 :exception => e)

        raise e
      end
    end

    Rails.logger.info("Billing process finished: #{results.inspect_all_things}")

    notify_billing_results(results) unless skip_notifications

    results
  end

  def self.notify_billing_results(results)
    BillingMailer.billing_finished(results).deliver_now unless results.successful?
  rescue => error
    System::ErrorReporting.report_error(error)
    env = Rails.env
    raise if env.test? || env.development?
  end

  delegate :notify_billing_results, to: :class

  def self.account_currency(account_id)
    Rails.cache.fetch("account:#{account_id}:billing_strategy:currency") do
      where(:account_id => account_id).pluck(:currency).first || false
    end || nil
    # the false trick is there for store it in memcache, because nil is not stored
  end

  def notify_billing_finished(now)
    only_on_days(now, 1) { notify_about_finalized_invoices }
    notify_about_expired_credit_cards(now)
  end

  def active?
    provider.approved?
  end

  def build_invoice(opts = {})
    options = opts.reverse_merge(period: Month.new(Time.now.utc.to_date))

    create_invoice_counter(options[:period])

    provider.buyer_invoices.new(options) do |new_invoice|
      new_invoice.creation_type = options[:creation_type] if options[:creation_type].present?
    end
  end

  def create_invoice!(opts = {})
    invoice = build_invoice(opts)
    Invoice.transaction { invoice.save! }
    invoice
  end

  def create_invoice(opts = {})
    invoice = build_invoice(opts)
    Invoice.transaction { invoice.save }
    invoice
  end

  def create_invoice_counter(period)
    invoice_prefix = (billing_monthly? ? period : period.begin.year).to_param
    InvoiceCounter.create(provider_account: account, invoice_prefix: invoice_prefix, invoice_count: 0)
  rescue ActiveRecord::RecordNotUnique
    InvoiceCounter.find_by(provider_account: account, invoice_prefix: invoice_prefix)
  end

  # TODO: Remove. See https://github.com/3scale/system/pull/9360
  def next_available_friendly_id(month, step = 1)
    return unless month
    id_prefix = billing_monthly? ? month : month.begin.year

    last_of_period = Invoice.by_provider(account)
                         .with_normalized_friendly_id(numbering_period, month)
                         .first
    order = if last_of_period
              last_of_period.friendly_id.split('-').last
            else
              0
            end
    "#{id_prefix.to_param}-#{'%08d' % (order.to_i + step)}"
  end

  # TODO: rename to invoice_numbering_monthly?
  def billing_monthly?
    numbering_period == 'monthly'
  end

  # TODO: rename to invoice_numbering_yearly?
  def billing_yearly?
    numbering_period == 'yearly'
  end

  def change_mode(bs_mode)
    return if bs_mode == self.type
    new_name = (name == 'prepaid') ? 'postpaid' : 'prepaid'
    self.update_attribute(:type, bs_mode.to_s)
    warning("Billing mode changed to #{new_name}")
  end

  def warning(txt, buyer = nil)
    LogEntry.log( :warning, txt, self.account_id, buyer)
  end

  def error(txt, buyer = nil)
    LogEntry.log( :error, txt, self.account_id, buyer)
  end

  def info(txt, buyer = nil)
    LogEntry.log( :info, txt, self.account_id, buyer)
  end

  protected

  delegate :provider_id_for_audits, :to => :account, :allow_nil => true

  def only_on_days(*days, &block)
    now = days.shift
    yield if days.include?(now.day)
  end


  def bill_expired_trials(buyer, now)
    buyer.billable_contracts_with_trial_period_expired(now - 1.day).find_each(batch_size: 50) do |contract|
      plan_type = contract.plan.class.model_name.human.downcase

      info("Billing account #{buyer.name} for #{plan_type} #{contract.plan.name} (just signed up or trial period expired)", buyer)
      contract.bill_for(Month.new(now), invoice_for(buyer, now))
    end
  end

  # TODO: DRY
  # TODO: cover it by unit tests
  #
  def bill_fixed_costs(buyer, now = Time.now.utc)
    Rails.logger.info "Billing fixed cost of account #{buyer.inspect} at #{now}"
    info("Billing fixed cost of account #{buyer.org_name}", buyer)
    buyer.billable_contracts.find_each(batch_size: 50) do |contract|
      contract.bill_for(Month.new(now), invoice_for(buyer, now))
    end
  end

  # Finalize all invoices that are in open but belong to
  # a period (month) that is already over.
  #
  def finalize_invoices_of(buyer, now = Time.now.utc)
    invoices_to_finalize_of(buyer, now).find_each(:batch_size => 20) do |invoice|
      info("Finalizing invoice for #{buyer.org_name} for period #{invoice.period}", buyer)
      invoice.finalize!
    end
  end

  def issue_invoices_of(buyer, now = Time.now.utc)
    to_issue = self.provider.buyer_invoices.by_buyer(buyer).finalized_before(now - 1.day - 22.hours)

    to_issue.find_each(batch_size: 100) do |invoice|
      info("Issuing invoice for #{buyer.org_name} for period #{invoice.period}", buyer)
      invoice.issue_and_pay_if_free!

      # TODO: extract to overloaded method?
      # TODO: Decouple the notification to observer
      if charging_enabled? && invoice.cost.nonzero? && invoice.buyer_account.paying_monthly?
        InvoiceMessenger.upcoming_charge_notification(invoice).deliver
      end
    end
  end

  def invoice_for_cinstance(contract)
    buyer = contract.buyer_account
    invoice_for(buyer, Time.now.utc)
  end

  def notify_about_finalized_invoices
    if provider.buyer_line_items.sum_by_invoice_state(:finalized) > 0
      info('Notifying about finalized invoices with non-zero cost')

      # do not send email if provider's using new notification system
      unless provider.provider_can_use?(:new_notification_system)
        AccountMessenger.invoices_to_review(provider).deliver
      end

      event = Invoices::InvoicesToReviewEvent.create(provider)
      Rails.application.config.event_store.publish_event(event)
    elsif provider.buyer_invoices.finalized.count > 0
      info('All finalized invoices have zero cost - notification not sent')
    end
  end

  def notify_about_expired_credit_cards(now)
    expiry_date = now.to_date + 10.days

    provider.buyers.expired_credit_card(expiry_date).find_each(:batch_size => 20) do |buyer|
      ignoring_find_each_scope do
        AccountMessenger.expired_credit_card_notification_for_buyer(buyer).deliver

        # do not send email if provider's using new notification system
        unless provider.provider_can_use?(:new_notification_system)
          AccountMessenger.expired_credit_card_notification_for_provider(buyer).deliver
        end

        event = Accounts::ExpiredCreditCardProviderEvent.create(buyer)
        Rails.application.config.event_store.publish_event(event)

        info('Notifying about expiring credit card', buyer)
      end
    end
  end

  def invoice_for(buyer, now)
    month = Month.new(now)
    Finance::InvoiceProxy.new(buyer, month)
  end

  def charge_invoices(buyer, now = Time.now.utc)
    if charging_enabled?
      if self.currency.nil?
        raise "BillingStrategy(#{self.id}) is trying to charge without currency settings"
      end

      buyer.invoices.chargeable(now).find_each(batch_size: 50) do |invoice|
        Rails.logger.info("Trying to charge invoice #{invoice.id}")
        invoice.charge!

      end
    else
      Rails.logger.info("Charging not enabled for #{account.org_name} - bypassing")
    end
  end

  def needs_credit_card?
    charging_enabled?
  end

  public :needs_credit_card?

  private

  # Yields a block for each buyer, passing it as a parameter. If an
  # exception occurs meanwhile, catches it and reports by airbrake.
  #
  def bill_and_charge_each(options = {})
    buyer_ids = options[:buyer_ids]
    @failed_buyers = []

    if provider.nil?
      airbrake(:error_message => "WARNING: tried to use billing strategy #{self.id} which has no account",
               :error_class => 'InvalidData')
      return
    end

    buyer_accounts = provider.buyer_accounts
    buyer_accounts = buyer_accounts.where(id: buyer_ids) if buyer_ids.present?
    buyer_accounts.find_each(:batch_size => 20) do |buyer|
      begin
        ignoring_find_each_scope { yield(buyer) }
      rescue => exception
        name = buyer.name
        buyer_id = buyer.id
        provider_id = provider.id

        msg = "Failed to bill or charge #{name}(#{buyer_id}) of provider(#{provider_id}): #{exception.message}\n"
        error(msg, buyer)
        airbrake(:error_message => msg,
                 :error_class => 'BillingError',
                 :parameters => { :buyer_id => buyer_id, :provider_id => provider_id },
                 :exception => exception)

        @failed_buyers << buyer_id
        raise if Rails.env.test?
      end
    end
  end

  def add_plan_cost(action, contract, plan, period)
    cost = plan.cost_for_period(period)

    if cost.nonzero?
      sign = action == :refund ? -1 : 1
      reason = action == :refund ? 'Refund' : 'Fixed fee'
      add_cost(contract, "#{reason} ('#{plan.name}')", period.to_s, cost * sign)
    end
  end

  def add_cost(contract, name, description, cost)
    invoice = invoice_for_cinstance(contract)
    Finance::BackgroundBilling.new(invoice).create_line_item!(
      {
        contract: contract,
        plan_id: contract.plan_id,
        name: name,
        description: description,
        quantity: 1,
        cost: cost,
        type: LineItem::PlanCost
      }
    )
  end

  module ErrorHandling
    def airbrake(*args)
      if Rails.env.production? || Rails.env.preview?
        System::ErrorReporting.report_error(*args)
      end
    end
  end

  # so that we have #airbrake as instance AND class method
  extend ErrorHandling
  include ErrorHandling

  module FindEachFix
    # HACK: to overcome find_each scoping, we reset the scope
    def ignoring_find_each_scope(&block)
      Account.unscoped.scoping(&block)
    end
  end

  extend  FindEachFix
  include FindEachFix
end

require_dependency 'finance/prepaid_billing_strategy'
require_dependency 'finance/postpaid_billing_strategy'

# frozen_string_literal: true

class SupportEntitlementsService
  attr_reader :account, :current_plan, :previous_plan, :invoice

  def initialize(account, opts = {})
    @account = account

    if account.has_bought_cinstance?
      application = account.bought_cinstance
      @current_plan = application.plan
      @previous_plan = opts[:previous_plan] || application.old_plan
    end

    @invoice = opts[:invoice] || find_invoice
  end

  def self.notify_entitlements(*args)
    new(*args).notify_entitlements
  end

  def notify_entitlements
    return unless entitlements_notification_enabled?

    if plan_downgrade? || recently_suspended?
      notify_entitlements_revoked
    elsif plan_entitled? && account.approved?
      notify_entitlements_assigned
    end
  end

  private

  def find_invoice
    Invoice.by_buyer(account).first
  end

  def entitlements_notification_enabled?
    ThreeScale.config.redhat_customer_portal.entitlements_notifications_enabled &&
      account.provider? &&
      account.field_value('red_hat_account_number').presence &&
      current_plan &&
      !enterprise_involved?
  end

  def enterprise_involved?
    plans = [current_plan, previous_plan].compact
    plans.any? do |plan|
      plan.system_name.to_s.include?(Logic::ProviderUpgrade::ENTERPRISE_PLAN)
    end
  end

  def plan_downgrade?
    return false unless previous_plan
    previous_plan.paid? && (current_plan.trial? || current_plan.free?)
  end

  def plan_entitled?
    (!previous_plan || previous_plan.free?) && (current_plan.trial? || current_plan.paid?)
  end

  def recently_suspended?
    current_plan.paid? && account.recently_suspended?
  end

  def notification_options
    opts = {}

    if !current_plan.trial? && invoice
      opts[:invoice_id] = invoice.id
      opts[:effective_since] = invoice.issued_on
    end

    opts[:effective_since] ||= Time.now.utc
    opts
  end

  def notify_entitlements_assigned
    AccountMailer.support_entitlements_assigned(account, notification_options).deliver_later
  end

  def notify_entitlements_revoked
    AccountMailer.support_entitlements_revoked(account, notification_options).deliver_later
  end
end

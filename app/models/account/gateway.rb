module Account::Gateway
  extend ActiveSupport::Concern

  included do
    has_many :payment_transactions
    has_one :payment_gateway_setting, dependent: :destroy, inverse_of: :account
    accepts_nested_attributes_for :payment_gateway_setting

    after_commit :update_payment_gateway, :if => :payment_gateway_changed

    attr_accessor :payment_gateway_changed
  end

  # Payment gateway this account accepts payments through.
  def payment_gateway
    @payment_gateway ||= begin
      case
      when payment_gateway_type.present?
        build_payment_geteway(payment_gateway_type, payment_gateway_options)
      when events.payment_setting_deleted.any?
        build_payment_geteway_from_event
      end
    end
  end

  def build_payment_geteway(gateway_type, gateway_options)
    gateway_class = PaymentGateway.implementation(gateway_type)
    gateway_class.new(gateway_options || {})
  end

  def build_payment_geteway_from_event
    event = events.payment_setting_deleted.last
    deleted_setting = PaymentGatewaySetting.new(event.metadata[:object_attributes], without_protection: true)
    build_payment_geteway(deleted_setting.gateway_type, deleted_setting.symbolized_settings)
  end

  def payment_gateway_setting_exists?
    payment_gateway_configured? || events.payment_setting_deleted.any?
  end

  def payment_gateway_configured?
    gateway_setting.persisted? && gateway_setting.configured?
  end

  # MIGRATION use separate table over columns in same table
  # Accessors for backward compatibility
  # There is an issue, build_association will automatically save the association on parent save
  # So invoking this method and saving Account instance will create a row in PaymentGatewaySetting table
  # But this is OK as we invoke Account#save AND Account#payment_gateway_options at the same time
  # in only one place: app/controllers/admin/account/payment_gateways_controller.rb via #change_payment_gateway!
  # Solution: The fix is to use nested attributes.
  def find_or_build_gateway_setting
    (payment_gateway_setting || build_payment_gateway_setting)
  end
  alias gateway_setting find_or_build_gateway_setting

  # MIGRATION use separate table over columns in same table
  # Accessors for backward compatibility
  def payment_gateway_type
    gateway_setting.gateway_type
  end

  # MIGRATION use separate table over columns in same table
  # Accessors for backward compatibility
  def payment_gateway_type=(type)
    gateway_setting.gateway_type = type
  end

  # MIGRATION use separate table over columns in same table
  # Accessors for backward compatibility
  def payment_gateway_options
    gateway_setting.symbolized_settings
  end

  # MIGRATION use separate table over columns in same table
  # Accessors for backward compatibility
  def payment_gateway_options=(hash)
    gateway_setting.gateway_settings = hash
  end

  # Payment gateway this account sends payments through.
  def provider_payment_gateway
    provider_account && provider_account.payment_gateway
  end

  def update_payment_gateway
    log_payment_gateway_change
    wipe_buyers_cc_details!
  end

  def change_payment_gateway!(type, settings)
    if self.payment_gateway_type != type.to_sym
      @payment_gateway_changed = true
    end

    gateway_setting.gateway_type = type
    gateway_setting.gateway_settings = settings

    save!
  end

  def log_payment_gateway_change
    Rails.logger.info("[Notification][Payment Gateway Change]: Account #{org_name} has" +
                      "changed payment gateway to #{payment_gateway_type}")
  end
end

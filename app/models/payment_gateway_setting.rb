# Use Setting not Option for name
# Option is meant for optional things
# Setting is for setting things up. In our case it is setting up the payment gateway
class PaymentGatewaySetting < ApplicationRecord
  belongs_to :account, inverse_of: :payment_gateway_setting
  serialize :gateway_settings
  symbolize :gateway_type
  validates :gateway_type, inclusion: {
    allow_nil: true,
    in: PaymentGateway.types
  }, length: { maximum: 255 }
  validate :active_gateway_type

  # By default AM::Gateway defines a #test? method
  # See https://github.com/activemerchant/active_merchant/blob/v1.44.1/lib/active_merchant/billing/gateway.rb#L146
  # We do not want that behaviour and only rely on AM::Base.gateway_mode
  # In our DB :test is stored for some providers

  def symbolized_settings
    (gateway_settings || {}).symbolize_keys.except(:test)
  end

  # FIXME: Put this validation later in AR validations
  # Intentionally not adding this in AR validations
  # Reason (Hery as of 13/05/2016) is that I do not know enough system to put it there.
  # I prefer validating manually in places where it is needed. Do not break things.
  def configured?
    return false if gateway_type.blank?
    fields = PaymentGateway.find(gateway_type).fields.keys
    fields.all? do |field|
      symbolized_settings[field].present?
    end
  end

  def active_gateway_type
    if gateway_type_changed? && PaymentGateway.find(gateway_type)&.deprecated?
      errors.add(:gateway_type, :invalid)
    end
  end
end

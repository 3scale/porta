# Use Setting not Option for name
# Option is meant for optional things
# Setting is for setting things up. In our case it is setting up the payment gateway
class PaymentGatewaySetting < ApplicationRecord
  include Symbolize
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

    gateway = PaymentGateway.find(gateway_type)

    return false unless gateway

    fields = gateway.non_boolean_fields

    fields.all? do |field, _label|
      symbolized_settings[field].present?
    end
  end

  # Overrides the {#gateway_setting} attribute by ensuring boolean fields are cast correctly
  # @note It would be nice to combine this with `attribute "#{boolean_field}"` and `gateway_setting` as an ActiveModel::Model
  # Sadly the attributes are dynamic, and meta-programming in this case would be overkill, still can be considered...
  # @param [Hash] hash with correct PaymentGateway fields
  # @return [Hash]
  #
  #   @example:
  #
  #   class GatewaySetting
  #     include ActiveModel::Model
  #
  #     attribute :name
  #     attribute :three_ds_enabled, :boolean
  #
  #     def self.load(str)
  #       new(JSON.load(str))
  #     end
  #
  #     def self.dump(obj)
  #       JSON.dump(obj.attributes)
  #     end
  #   end
  #
  #   class PaymentGatewaySetting < Gateway
  #     serialize :gateway_settings, GatewaySetting
  #   end
  #
  def gateway_settings=(hash)
    gateway = PaymentGateway.find(gateway_type)

    return super unless gateway

    gateway.boolean_field_keys.each do |field|
      hash[field] = ActiveModel::Type::Boolean.new.cast(hash[field])
    end

    super(hash)
  end

  def active_gateway_type
    errors.add(:gateway_type, :invalid) if will_save_change_to_gateway_type? && PaymentGateway.find(gateway_type)&.deprecated?
  end
end

# frozen_string_literal: true

class Accounts::PaymentSettingDeletedEvent < BillingRelatedEvent

  class << self
    def create(payment_setting)
      account = payment_setting.account
      attributes = payment_setting.attributes.symbolize_keys.except(:created_at, :updated_at)

      new(
        account: account,
        metadata: {
          provider_id: account.id,
          object_attributes: attributes
        }
      )
    end

    def valid?(payment_setting)
      account = payment_setting.account
      account.provider? && payment_setting.configured? && account.scheduled_for_deletion?
    end
  end
end

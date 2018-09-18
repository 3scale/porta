# frozen_string_literal: true

# This is a logic of buyer for charging and CC
#
# FIXME: Those methods seem to be similar, cleaning is needed
module Logic
  module Buyer
    def is_charged?
      provider_account.billing_strategy.try!(:needs_credit_card?) &&
        settings.monthly_charging_enabled?
    end

    def credit_card_needed?
      bought_plans.any?(&:paid?) && is_charged?
    end

    # TODO: test this method
    def credit_card_missing?
      credit_card_needed? && !credit_card_stored?
    end

    # TODO: test this method
    def credit_card_editable?
      # HACK: HACK HACK
      return false if master?
      provider_account.payment_gateway_configured? && provider_account.billing_strategy.try!(:charging_enabled?)
    end

    def requires_credit_card_now?
      provider_account.settings.require_cc_on_signup.visible? &&
        credit_card_editable? &&
        credit_card_missing?
    end
  end
end
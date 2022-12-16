# frozen_string_literal: true

# TODO: will be removed once features/old/providers/wizard_upgrade_plan.feature is refactored
Given "Braintree is stubbed for wizard" do
  stub_payment_gateway_authorization(:braintree_blue)
  stub_payment_gateway_update(:braintree_blue)
end

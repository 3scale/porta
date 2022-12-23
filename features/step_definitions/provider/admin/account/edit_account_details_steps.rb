# frozen_string_literal: true

# TODO: will be removed once features/old/providers/wizard_upgrade_plan.feature is refactored
Given "Braintree is stubbed for wizard" do
  stub_braintree_authorization
  stub_successful_braintree_update
end

# frozen_string_literal: true

Then "I enter my credit card details" do
  stub_payment_gateway_authorization(:braintree_blue)
  stub_payment_gateway_update(:braintree_blue)

  click_on 'enter your Credit Card details'
  assert_equal admin_account_braintree_blue_path, current_path

  click_on 'Add Credit Card Details and Billing Address'
  fill_in_braintree_form

  click_on 'Save details'
end

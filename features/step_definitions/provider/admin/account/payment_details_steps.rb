# frozen_string_literal: true

Given "{provider_or_buyer} has last digits of credit card number {string} and {expiration_date}" do |account, partial_number, expiration_date|
  account.update!(credit_card_partial_number: partial_number,
                  credit_card_auth_code: 'valid_code',
                  credit_card_expires_on: expiration_date)
end

Given /^the payment gateway will fail on (authorize|store)$/ do |operation|
  ActiveMerchant::Billing::BogusGateway.will_fail!(operation)
end

Then "links to Terms of service, Privacy and Refund policies should be visible" do
  assert find("#terms-link")[:href] =~ /#{current_account.provider_account.settings.cc_terms_path}\Z/
  assert find("#privacy-link")[:href] =~ /#{current_account.provider_account.settings.cc_privacy_path}\Z/
  assert find("#refunds-link")[:href] =~ /#{current_account.provider_account.settings.cc_refunds_path}\Z/
end

# TODO: there are too many steps for payment gateway, there should only be one to configure a provider. This one looks good.
# Maybe these "all purpose" steps should be moved to the provider/ level instead of being under provider/admin/account
Given "{provider} manages payments with {string}" do |provider, payment_gateway_type|
  provider.update!(payment_gateway_type: payment_gateway_type.to_sym)
end

Given "the provider has unconfigured payment gateway" do
  @provider.update!(payment_gateway_type: 'stripe',
                    payment_gateway_options: { login: '3Scale' })
end

Given "{provider} has testing credentials for braintree" do |provider|
  PaymentGateways::BrainTreeBlueCrypt.any_instance.stubs(:find_customer).returns(nil)
  provider.update!(payment_gateway_type: :braintree_blue,
                   payment_gateway_options: { :public_key => 'AnY-pUbLiC-kEy', :merchant_id => 'my-payment-gw-mid', :private_key => 'a1b2c3d4e5' })
end

Given "Braintree is stubbed for wizard" do
  PaymentGateways::BrainTreeBlueCrypt.any_instance.stubs(:form_url).returns(hosted_success_provider_admin_account_braintree_blue_path(next_step: 'upgrade_plan'))
end

When "I fill in the braintree credit card form" do
  fill_braintree_payment_details_form
end

When "I fill in the braintree credit card iframe" do
  find(:css, '#braintree_nonce', visible: :hidden).set('some_braintree_nonce')
end

When "reviewing the provider's payment details" do
  select_context 'Account Settings'
  click_on 'Billing'
  click_link 'Payment Details'
end

When "an admin wants to add payment details" do
  select_context 'Account Settings'
  click_on 'Billing'
  click_on 'Payment Details'
  click_on 'Add Payment Details'
end

# Braintree only
Given "the provider has already set payment details" do
  # HACK: These are the fields consulted by Account::CreditCard#credit_card_stored?
  @provider.update!(credit_card_partial_number: '1234', credit_card_auth_code: 'valid_code')
end

Then "the provider's payment details can be added" do
  fill_braintree_payment_details_form
  click_on 'Save'
  assert_braintree_payment_details
  assert_flash 'Credit card details were successfully stored.'
end

Then "the admin can edit the provider's payment details" do
  # FIXME: it should be possible to edit only certain fields without adding the credit card data again
  click_on 'Edit'
  fill_braintree_payment_details_form
  click_on 'Save'
  assert_braintree_payment_details
  assert_flash 'Credit card details were successfully stored.'
end

# Braintree only
When /^the admin will add an? (in)?valid credit card$/ do |invalid|
  PaymentGateways::BrainTreeBlueCrypt.any_instance
                                     .stubs(:confirm)
                                     .returns(invalid.present? ? failed_braintree_result : successful_braintree_result)
end

Then "the provider's payment details can't be added" do
  click_on 'Add Payment Details'
  assert_flash 'invalid merchant id'
  assert_equal provider_admin_account_braintree_blue_path, current_path
end

Then "the provider's payment details can't be stored" do
  fill_braintree_payment_details_form
  click_on 'Save credit card'

  assert_text 'Your payment details could not be saved'
  assert_text 'Credit card number is invalid'
  assert_flash 'Something went wrong and billing information could not be stored.'
end

Then "the provider's payment details are not accessible" do
  select_context 'Account Settings'
  within '.pf-c-page__sidebar' do
    assert has_no_css?('li', text: 'Billing')
  end
end

Then "an admin can remove the provider's the payment details" do
  click_link 'Remove Payment Details'
  accept_confirm('Are you sure?')
  assert_flash 'Your credit card was successfully removed'

  within '.SettingsBox' do
    assert_content 'Add Payment Details'
  end
end

def fill_braintree_payment_details_form
  fill_in("First name", with: "Bender", visible: true)
  fill_in("Last name", with: "Rodriguez", visible: true)
  fill_in("Company", with: "comp", visible: true)
  fill_in("Street address", with: "C/LLacuna 162", visible: true)
  fill_in("City", with: "Barcelona", visible: true)
  fill_in("State/Region", with: "Catalonia", visible: true)
  fill_in("ZIP / Postal Code", with: "08080", visible: true)
  fill_in("Phone", with: "+34123123212", visible: true)
  find_field("Country").find(:option, "Spain").select_option

  # Simulates getClient and getHostedFields working in braintree_edit_form.ts
  page.evaluate_script("document.querySelector('#braintree_nonce').value = 'some_braintree_nonce'")
  page.evaluate_script("document.querySelector('button[type=\"submit\"]').disabled = false")
end

def assert_braintree_payment_details
  assert_content 'Credit card number'
  assert_content "XXXX-XXXX-XXXX-#{current_account.credit_card_partial_number}"
  assert_content 'Expiration date'
  assert_content current_account.credit_card_expires_on.strftime('%B %Y')
end

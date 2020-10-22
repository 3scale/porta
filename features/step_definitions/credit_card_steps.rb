# frozen_string_literal: true

Given /^((?:buyer|provider) "[^\"]*") has last digits of credit card number "([^\"]*)" and expiration date (.*)$/ do |account, partial_number, expiration_date|
  account.credit_card_partial_number = partial_number
  account.credit_card_auth_code = 'valid_code'
  account.credit_card_expires_on = Date.parse(expiration_date)
  account.save!
end

Given "buyer {string} has( a) valid credit card" do |buyer_name|
  step %(buyer "#{buyer_name}" has a valid credit card with lots of money)
end

Given "buyer {string} has( a) valid credit card with {balance}" do |buyer_name, balance|
  buyer = Account.find_by!(org_name: buyer_name)

  buyer.credit_card_expires_on_year = 2.years.from_now.year
  buyer.credit_card_expires_on_month = 2.years.from_now.month
  buyer.credit_card_auth_code = "valid_if_ends_with_one_#{balance}"

  buyer.save!
end

Given "the buyer has a valid credit card" do |buyer_name|
  step %(the buyer has a valid credit card with lots of money)
end

Given "the buyer has a valid credit card with {balance}" do |balance|
  step %(buyer "#{@buyer.org_name}" has a valid credit card with #{balance})
end

Given "the payment gateway will fail on {word}" do |operation|
  ActiveMerchant::Billing::BogusGateway.will_fail!(operation)
end

When "I select {string} from Countr" do |country|
  step %(I select "#{country}" from "account_billing_address_country")
end

Then "I should see the legal terms link linking to path {string}" do |path|
  assert find("#terms-link")[:href] =~ /#{path}\Z/
end

Then "I should see the privacy link linking to path {string}" do |path|
  assert find("#privacy-link")[:href] =~ /#{path}\Z/
end

Then "I should see the refunds link linking to path {string}" do |path|
  assert find("#refunds-link")[:href] =~ /#{path}\Z/
end

Given "{provider} manages payments with {string}" do |provider, payment_gateway_type|
  provider.payment_gateway_type = payment_gateway_type.to_sym
  provider.save!
end

Given "the provider has unconfigured payment gateway" do
  @provider.payment_gateway_type = 'stripe'
  @provider.payment_gateway_options = { login: '3Scale'}
  @provider.save!
end

Given "{provider} has testing credentials for braintree" do |provider|
  PaymentGateways::BrainTreeBlueCrypt.any_instance.stubs(:find_customer).returns(nil)
  provider.payment_gateway_type = :braintree_blue
  provider.payment_gateway_options = {
    public_key: 'AnY-pUbLiC-kEy',
    merchant_id: 'my-payment-gw-mid',
    private_key: 'a1b2c3d4e5'
  }
  provider.save!
end

Given "the provider has testing credentials for braintree" do
  step %(provider "#{@provider.domain}" has testing credentials for braintree)
end
Given "Braintree is stubbed for wizard" do
  PaymentGateways::BrainTreeBlueCrypt.any_instance.stubs(:form_url).returns(hosted_success_provider_admin_account_braintree_blue_path(next_step: 'upgrade_plan'))
end

Given "Braintree is stubbed to (not )accept credit card" do
  PaymentGateways::BrainTreeBlueCrypt.any_instance.stubs(customer_id_mismatch?: false)
  PaymentGateways::BrainTreeBlueCrypt.any_instance.stubs(:find_customer).returns(nil)
  PaymentGateways::BrainTreeBlueCrypt.any_instance.stubs(:create_customer_data).returns(nil)
  PaymentGateways::BrainTreeBlueCrypt.any_instance.stubs(:authorization).returns(nil)
  PaymentGateways::BrainTreeBlueCrypt.any_instance.stubs(:find_customer).returns(nil)

  PaymentGateways::BrainTreeBlueCrypt.any_instance.stubs(:confirm).returns(failed ? failed_braintree_result : successful_braintree_result)
end

Given "Braintree is stubbed to accept credit card for buyer" do
  step 'Braintree is stubbed to accept credit card'
  step 'Braintree returns successful stubbed credit card'
end

Given "Braintree returns successful stubbed credit card" do
  PaymentGateways::BrainTreeBlueCrypt.any_instance.stubs(:confirm).returns(successful_braintree_result)
end

When "I fill in the braintree credit card form" do
  data = <<-TABLE
  | First name                | Pepe                    |
  | Last name                 | Ventura                 |
  | Phone                     | +2342342342             |
  | Company                   | comp                    |
  | Street address            | Calle Simpecado         |
  | ZIP / Postal Code         | 4242                    |
  | City                      | Sevilla                 |
  | State/Region              | Andalusia               |
  TABLE
  step 'I fill in the braintree credit card iframe'
  step 'I fill in the following:', table(data)
  step 'I select "Spain" from "Country"'
end

# This will mock filling in the braintree hidden parameters
When "I fill in the braintree credit card iframe" do
  # TODO: Would be better to not rely on this kind of variables
  if @javascript
    page.evaluate_script("document.querySelector('#braintree_nonce').value = 'some_braintree_nonce'")
  else
    find(:css, '#braintree_nonce', visible: :hidden).set('some_braintree_nonce')
  end
end

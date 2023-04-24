# frozen_string_literal: true

But "{provider} doesn't have a payment gateway set up" do |provider|
  provider.update!(payment_gateway_type: nil, payment_gateway_options: nil)
end

But "the provider's payment gateway is unconfigured" do
  @provider.update!(payment_gateway_options: nil)
end

Given "they are reviewing the charging and gateway billing settings" do
  visit admin_finance_settings_path
end

Given "an active user {has} access to admin section finance" do |have_access|
  @user = FactoryBot.create(:active_user, account: @provider, username: 'user_with_access')
  @user.member_permissions.create!(admin_section: 'finance') if have_access
end

Then "they should not be able to review the charging and gateway billing settings" do
  visit admin_finance_settings_path
  assert_text 'Access Denied'
end

Then "charging can be enabled" do
  check('Charging enabled')
  click_button('Save')
  assert_flash('Finance settings updated.')
  assert has_checked_field?('Charging enabled')
end

Then "payment gateway {can} be set" do |visible|
  assert_equal visible, has_checked_field?('Charging enabled')
  assert_equal visible, has_text?('Credit card gateway')
  assert_equal visible, has_css?(credit_card_gateway_card_selector)
end

Then "they can set a different currency to be charged" do
  assert has_select?('Currency', selected: 'USD - American Dollar')
  select('EUR - Euro', from: 'Currency')
  click_button('Save')
  assert_flash('Finance settings updated.')
end

And "buyers will receive new invoices with that currency" do
  buyer = FactoryBot.create(:buyer_account, provider_account: @provider)
  buyer.buy!(@provider.account_plans.default)

  create_invoice(buyer, tested_invoice_date)

  visit admin_finance_root_path
  assert has_css?('td.u-amount', text: 'EUR')
  assert_not has_css?('td.u-amount', text: 'USD')
end

And "a buyer has been billed monthly" do
  @buyer = FactoryBot.create(:buyer_account, provider_account: @provider)
  @buyer.buy!(@provider.account_plans.default)

  create_invoice(@buyer, tested_invoice_date)
end

Then "they can set the billing period to yearly" do
  assert has_select?('Billing periods for invoice ids', selected: 'monthly')
  select('yearly', from: 'Billing periods for invoice ids')
  click_button('Save')
  assert_flash("Finance settings updated. Already existent invoices won't change their id.")
end

And "only new invoices will change their id" do
  assert @provider.reload.billing_strategy.billing_yearly?
  assert_equal "2022-12-00000001", @buyer.invoices.last.friendly_id # Month period defined by tested_invoice_date
  assert_equal "2022-00000001", @provider.billing_strategy.next_available_friendly_id(Month.new(tested_invoice_date))
end

Given "{provider} is billing but not charging" do |provider|
  set_provider_charging_with(provider: provider, payment_gateway: :bogus, charging_enabled: false)
end

Given "{provider} is charging its buyers" do |provider|
  set_provider_charging_with(provider: provider, payment_gateway: :bogus)
end

Given "{provider} is charging its buyers with {payment_gateway}" do |provider, payment_gateway|
  set_provider_charging_with(provider: provider, payment_gateway: payment_gateway)
end

When "{} in {billing_mode} mode" do |lstep, billing_mode|
  step lstep

  @provider.billing_strategy.change_mode(billing_mode)
end

Given /^the provider is charging its buyers with a (supported|deprecated) payment gateway$/ do |deprecation_state|
  ::PaymentGateway.any_instance.expects(:deprecated?).returns(deprecation_state == 'deprecated').once
  set_provider_charging_with(provider: @provider, payment_gateway: :bogus)
end

Then "they {should} be warned about the payment gateway being deprecated" do |deprecated|
  assert_equal deprecated, has_text?(/^The .+ gateway has been deprecated. It can still be used but you won't be able to switch back to it once you confirmed the switch to another gateway.$/)
end

Then "Stripe can be set as a payment gateway" do
  within_credit_card_gatewat_card do
    select('Stripe', from: 'Gateway')
    fill_in('Secret Key', with: 'secret')
    fill_in('Publishable Key', with: 'publishable')
    fill_in('Webhook Signing Secret', with: 'webhook')

    save_changes_and_confirm
  end
  assert_flash 'Payment gateway details were successfully saved.'
end

Then "Braintree can be set as a payment gateway" do
  within_credit_card_gatewat_card do
    select('Braintree', from: 'Gateway')
    fill_in('Public Key', with: 'public')
    fill_in('Private Key', with: 'private')
    fill_in('Merchant ID', with: 'merchant_id')
    check('3D Secure enabled')

    save_changes_and_confirm
  end
  assert_flash 'Payment gateway details were successfully saved.'
end

Given "master {is} billing tenants" do |master_billing_enabled|
  ThreeScale.stubs(master_billing_enabled?: master_billing_enabled)
end

def within_credit_card_gatewat_card(&block)
  within(credit_card_gateway_card_selector) do
    yield block
  end
end

def credit_card_gateway_card_selector
  'form#payment-gateway-form'
end

def save_changes_and_confirm
  accept_confirm do
    accept_confirm do
      click_button 'Save changes'
    end
  end
end

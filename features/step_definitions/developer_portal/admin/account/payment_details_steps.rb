# frozen_string_literal: true

Given "{buyer} has a valid credit card" do |buyer|
  buyer.update!(credit_card_partial_number: '1234' || credit_card_example_data[:partial_number],
                credit_card_expires_on: @expiration_date || buyer_credit_card_expiration_date,
                credit_card_auth_code: @credit_card_auth_code || credit_card_example_data[:auth_code])
end

Given "{} with no money" do |lstep|
  @credit_card_auth_code = 'valid_if_ends_with_one_2'
  step lstep
end

Given "{} that expires on {date}" do |lstep, date|
  @expiration_date = date
  step lstep
end

When "the buyer is reviewing their account settings" do
  visit '/'
  click_on 'Settings'
end

When "the buyer is reviewing their credit card details" do
  stub_stripe_intent_setup if @buyer.reload.provider_account.payment_gateway_type == :stripe # Only stripe need to be stubbed
  visit admin_account_path
  credit_card_details_tab.click
end

When "the buyer enters the generic credit card details URL manually" do
  stub_stripe_intent_setup if @buyer.reload.provider_account.payment_gateway_type == :stripe # Only stripe need to be stubbed
  visit admin_account_payment_details_path
end

Then "the buyer should be redirected to the {word} page" do |payment_gateway|
  assert_equal path_to("the #{payment_gateway} credit card details page"), current_path
end

Then "the buyer can't add or update any billing information" do
  assert_raise(Capybara::ElementNotFound) { credit_card_details_tab }
  visit admin_account_payment_details_path
  assert_text 'Access Denied'
end

Given "the buyer {has} added their billing address" do |has_address|
  if has_address
    @buyer.billing_address = { name: billing_address[:first_name],
                               address1: billing_address[:street_address],
                               address2: billing_address[:extra_address],
                               city: billing_address[:locality],
                               country: billing_address[:country_name],
                               state: billing_address[:region],
                               zip: billing_address[:postal_code],
                               phone: billing_address[:phone] }
  else
    @buyer.delete_billing_address
  end
  @buyer.save!
end

Given "the buyer {has} added their credit card details" do |has_address|
  if has_address
    @buyer.update(credit_card_auth_code: credit_card[:auth_code],
                  credit_card_expires_on_year: credit_card[:expiration_year],
                  credit_card_expires_on_month: credit_card[:expiration_month],
                  credit_card_partial_number: credit_card[:partial_number] )
  else
    @buyer.delete_cc_details
  end
  @buyer.save!
end

Then "the buyer can see their billing information" do
  stub_stripe_intent_setup if @buyer.reload.provider_account.payment_gateway_type == :stripe # Only stripe need to be stubbed

  credit_card_details_tab.click
  assert_buyer_billing_address_details
  assert_buyer_credit_card_details
end

Then "the buyer can add their billing address for the first time for stripe" do
  stub_stripe_intent_setup(times: 2)

  credit_card_details_tab.click
  assert_not has_css?(billing_address_descriptionlist_selector)

  click_on 'First add a billing address'
  fill_in_buyer_stripe_form
  click_on 'Save'

  assert_flash 'Your billing address was successfully stored'
  assert_buyer_billing_address_details
end

Then "the buyer can't add an incomplete billing address for stripe" do
  stub_stripe_intent_setup

  credit_card_details_tab.click

  click_on 'First add a billing address'
  fill_in_buyer_stripe_form({})
  click_on 'Save'

  assert_flash 'Failed to update your billing address data. Check the required fields'
  assert_equal admin_account_payment_details_path, current_path
  assert_buyer_stripe_form_errors
end

But "credit card information still needs to be added" do
  within(billing_address_descriptionlist_selector) do
    assert_not has_css?('dt', text: 'Credit card number')
    assert_not has_css?('dt', text: 'Expiration date')
  end
  # TODO: assert stripe js widget
end

Then "the buyer can update their billing address for stripe" do
  stub_stripe_intent_setup(times: 2)
  credit_card_details_tab.click
  assert has_css?(billing_address_descriptionlist_selector)

  click_on 'Edit billing address'
  new_billing_address = billing_address.merge({ address_address: 'West 57th Street' })
  fill_in_buyer_stripe_form(new_billing_address)
  click_on 'Save'

  assert_flash 'Your billing address was successfully stored'
  assert_buyer_billing_address_details(new_billing_address)
end

Then "the buyer can't add their credit card" do
  assert_not has_css?('#stripe-form-wrapper')
end

Then "the buyer can add their credit card for stripe" do
  pending("TODO: When adding the credit card with the Stripe's widget, the browser make all kinds of requests to the actual API from Stripe. If we manage to mock this then it will be OK to test it.")

  # credit_card_details_tab.click
  # assert_buyer_billing_address_details

  # within_frame(find('[name^="__privateStripeFrame"]')) do
  #   fill_in('cardnumber', with: '4111111111111111')
  #   fill_in('exp-date', with: '1223')
  #   fill_in('cvc', with: '123')
  #   fill_in('postal', with: '12345')
  # end

  # within('#stripe-form') do
  #   click_on 'Save details'
  # end
end

Then "the buyer can update their credit card" do
  pending("TODO: When adding the credit card with the Stripe's widget, the browser make all kinds of requests to the actual API from Stripe. If we manage to mock this then it will be OK to test it.")
end

Then /^the buyer can add their credit card and billing address for Braintree( for the first time)?$/ do |first_time|
  credit_card_details_tab.click
  assert_equal first_time.blank?, has_css?(billing_address_descriptionlist_selector)

  step('the buyer adds their credit card details for Braintree')
end

And "the buyer adds their credit card details for Braintree" do
  stub_braintree_authorization
  click_on 'Add Credit Card Details and Billing Address'

  fill_in_braintree_form

  stub_successful_braintree_update
  click_on 'Save details'

  assert_flash 'CREDIT CARD DETAILS WERE SUCCESSFULLY STORED'
  assert_buyer_billing_address_details
  assert_buyer_credit_card_details
end

Then "the buyer can update their credit card and billing address for Braintree" do
  stub_braintree_authorization
  credit_card_details_tab.click
  assert has_css?(billing_address_descriptionlist_selector)

  click_on 'Edit Credit Card Details and Billing Address'
  new_billing_address = billing_address.merge({ street_address: 'West 57th Street' })
  new_credit_card = credit_card.merge({ partial_number: '5678' })

  fill_in_braintree_form(new_billing_address)

  stub_successful_braintree_update(billing_address: new_billing_address, credit_card: new_credit_card)
  click_on 'Save details'

  assert_flash 'CREDIT CARD DETAILS WERE SUCCESSFULLY STORED'
  within(billing_address_descriptionlist_selector) do
    find('dt', text: 'Address').assert_sibling('dd', text: 'West 57th Street')
    find('dt', text: 'Credit card number').assert_sibling('dd', text: "XXXX-XXXX-XXXX-5678")
  end
end

private

def billing_address
  billing_address_example_data
end

def credit_card_details_tab
  find('.nav-tabs li a', text: /credit card details/i)
end

def billing_address_descriptionlist_selector
  '#billing_address'
end

# This smells of :reek:statementsTooManyStatements but we don't care
def fill_in_buyer_stripe_form(obj = billing_address_example_data)
  fill_in('account[billing_address][name]', with: obj[:first_name])
  fill_in('account[billing_address][address1]', with: obj[:street_address])
  fill_in('account[billing_address][address2]', with: obj[:extra_address])
  fill_in('account[billing_address][city]', with: obj[:locality])
  find_field('account[billing_address][country]').find(:option, obj[:country_name]).select_option
  fill_in('account[billing_address][state]', with: obj[:region])
  fill_in('account[billing_address][phone]', with: obj[:phone])
  fill_in('account[billing_address][zip]', with: obj[:postal_code])
end

def assert_buyer_stripe_form_errors
  within('[name="Billing Address"]') do
    has_css?('input[name="account[billing_address][name]"] + p.inline-errors', text: "can't be blank")
    has_css?('input[name="account[billing_address][address1]"] + p.inline-errors', text: "can't be blank")
    has_css?('input[name="account[billing_address][address2]"] + p.inline-errors', text: "can't be blank")
    has_css?('input[name="account[billing_address][city]"] + p.inline-errors', text: "can't be blank")
    has_css?('select[name="account[billing_address][country]"] + p.inline-errors', text: "can't be blank")
  end
end

def fill_in_braintree_form(obj = billing_address_example_data) # rubocop:disable Metrics/AbcSize
  fill_in('customer[first_name]', with: obj[:first_name], visible: true)
  fill_in('customer[last_name]', with: obj[:last_name], visible: true)
  fill_in('customer[phone]', with: obj[:phone], visible: true)
  fill_in('customer[credit_card][billing_address][company]', with: obj[:company], visible: true)
  fill_in('customer[credit_card][billing_address][street_address]', with: obj[:street_address], visible: true)
  fill_in('customer[credit_card][billing_address][postal_code]', with: obj[:postal_code], visible: true)
  fill_in('customer[credit_card][billing_address][locality]', with: obj[:locality], visible: true)
  fill_in('customer[credit_card][billing_address][region]', with: obj[:region], visible: true)
  find_field('customer[credit_card][billing_address][country_name]').find(:option, obj[:country_name]).select_option

  # HACK: we don't fill in credit card details because we would call Braintree API. Instead we stub BrainTreeBlueCrypt response.
  # Simulates getClient and getHostedFields working in braintree_edit_form.ts
  page.evaluate_script("document.querySelector('#braintree_nonce').value = 'some_braintree_nonce'")
  page.evaluate_script("document.querySelector('button[type=\"submit\"]').disabled = false")
end

def assert_buyer_billing_address_details(obj = billing_address_example_data)
  within(billing_address_descriptionlist_selector) do
    find('dt', text: 'Address').assert_sibling('dd', text: obj[:street_address])
    find('dt', text: 'Zip').assert_sibling('dd', text: obj[:postal_code])
    find('dt', text: 'City').assert_sibling('dd', text: obj[:locality])
    find('dt', text: 'State').assert_sibling('dd', text: obj[:region])
    find('dt', text: 'Country').assert_sibling('dd', text: obj[:country_name])
    find('dt', text: 'Phone').assert_sibling('dd', text: obj[:phone])
  end
end

def assert_buyer_credit_card_details(obj = credit_card_example_data)
  within(billing_address_descriptionlist_selector) do
    find('dt', text: 'Credit card number').assert_sibling('dd', text: "XXXX-XXXX-XXXX-#{obj[:partial_number]}")
    find('dt', text: 'Expiration date').assert_sibling('dd', text: buyer_credit_card_expiration_date(obj).strftime('%B, %Y'))
  end
end

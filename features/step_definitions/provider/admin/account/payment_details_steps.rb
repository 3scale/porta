# frozen_string_literal: true

Then "links to Terms of service, Privacy and Refund policies should be visible" do
  assert find("#terms-link")[:href] =~ /#{current_account.provider_account.settings.cc_terms_path}\Z/
  assert find("#privacy-link")[:href] =~ /#{current_account.provider_account.settings.cc_privacy_path}\Z/
  assert find("#refunds-link")[:href] =~ /#{current_account.provider_account.settings.cc_refunds_path}\Z/
end

Given "a(n) {valid} account" do |valid|
  Account.any_instance.stubs(:valid?).returns(valid) # TODO: why is account not valid in the first place?
end

Given "the master provider {has} configured a payment gateway" do |correct|
  stub_braintree_configuration(correct: correct)
end

When "I fill in the braintree credit card form" do
  fill_in_braintree_form
end

When "I fill in the braintree credit card iframe" do
  find(:css, '#braintree_nonce', visible: :hidden).set('some_braintree_nonce')
end

When "(an admin is )reviewing the provider's payment details" do
  visit edit_provider_admin_account_path
  select_vertical_nav_section 'Payment Details'
end

Given "an admin has already set the provider's payment details" do
  @provider.update!(
    credit_card_partial_number: credit_card_example_data[:partial_number],
    credit_card_expires_on_year: credit_card_example_data[:expiration_year],
    credit_card_expires_on_month: credit_card_example_data[:expiration_month],
    credit_card_auth_code: credit_card_example_data[:auth_code],
    billing_address_first_name: billing_address_example_data[:first_name],
    billing_address_last_name: billing_address_example_data[:last_name],
    billing_address_phone: billing_address_example_data[:phone],
    billing_address_name: billing_address_example_data[:name],
    billing_address_address1: billing_address_example_data[:address1],
    billing_address_city: billing_address_example_data[:city],
    billing_address_country: billing_address_example_data[:country],
    billing_address_state: billing_address_example_data[:state],
    billing_address_zip: billing_address_example_data[:zip]
  )
end

Then "the provider's payment details {can} be added" do |will_be_added|
  click_on 'Add Payment Details'

  if will_be_added
    fill_in_braintree_form
    click_on 'Save'
    assert_flash 'Credit card details were successfully stored.'
    assert_provider_payment_details
  else
    assert_flash 'Invalid merchant id'
    assert_equal provider_admin_account_braintree_blue_path, current_path
  end
end

Then "the provider's payment details can be added only after completing account information" do
  click_on 'Add Payment Details'

  assert_text 'Edit Account Details'
  assert_match 'next_step=credit_card', current_url
  assert_equal @provider.domain, find(:label, text: I18n.t('activerecord.attributes.account.org_name')).sibling('input').value
  assert_equal 'UTC', find(:label, text: I18n.t('activerecord.attributes.account.timezone')).sibling('select').value
  assert has_css?(:button, text: I18n.t('provider.admin.accounts.form.submit_button_next_step_label'))
end

Then "the admin can edit the provider's payment details" do
  stub_payment_gateway_authorization(:braintree_blue)
  click_on 'Edit'

  new_billing_address = billing_address.merge({ company: 'Friendly Robot Company' })
  fill_in_braintree_form(new_billing_address)

  stub_payment_gateway_update(:braintree_blue, billing_address: new_billing_address)
  click_on 'Save'

  within('section', text: 'Billing Address') do
    find('dt', text: 'Company').assert_sibling('dd', text: 'Friendly Robot Company')
  end
  assert_flash 'Credit card details were successfully stored.'
end

When /^the admin will add an? (in)?valid credit card$/ do |invalid|
  stub_payment_gateway_authorization(:braintree_blue, times: invalid ? 2 : 1)
  stub_payment_gateway_update(:braintree_blue, success: !invalid)
end

But "there is a customer id mismatch" do
  expect_braintree_customer_id_mismatch
end

Then "the provider's payment details can't be stored because the card number is invalid" do
  click_on 'Add Payment Details'
  fill_in_braintree_form
  click_on 'Save credit card'

  assert_text 'Your payment details could not be saved'
  assert_text 'Credit card number is invalid'
  assert_flash 'Something went wrong and billing information could not be stored.'
end

Then "the provider's payment details can't be stored because something went wrong" do
  click_on 'Add Payment Details'
  fill_in_braintree_form
  click_on 'Save credit card'

  assert_flash 'Credit Card details could not be stored.'
end

Then "the provider's payment details are not accessible" do
  visit edit_provider_admin_account_path
  assert_not section_from_vertical_nav?('Billing')
end

Then "an admin can remove the provider's payment details" do
  ActiveMerchant::Billing::Gateway.any_instance.expects(:threescale_unstore).returns(true)

  click_on 'Remove Payment Details'
  accept_confirm('Are you sure?')
  assert_flash 'Your credit card was successfully removed'

  within '.SettingsBox' do
    assert_content 'Add Payment Details'
  end
end

Given "{provider} doesn't have billing address" do |provider|
  provider.delete_billing_address
  provider.save!
end

def assert_provider_payment_details # rubocop:disable Metrics/AbcSize
  within('section', text: 'Personal Details') do
    find('dt', text: 'First Name').assert_sibling('dd', text: billing_address_example_data[:first_name])
    find('dt', text: 'Last Name').assert_sibling('dd', text: billing_address_example_data[:last_name])
    find('dt', text: 'Phone').assert_sibling('dd', text: billing_address_example_data[:phone])
  end

  within('section', text: 'Credit Card Details') do
    find('dt', text: 'Credit card number').assert_sibling('dd', text: "XXXX-XXXX-XXXX-#{credit_card_example_data[:partial_number]}")
    find('dt', text: 'Expiration date').assert_sibling('dd', text: buyer_credit_card_expiration_date.strftime('%B %Y'))
  end

  within('section', text: 'Billing Address') do
    find('dt', text: 'Company').assert_sibling('dd', text: billing_address_example_data[:company])
    find('dt', text: 'Address').assert_sibling('dd', text: billing_address_example_data[:street_address])
    find('dt', text: 'Zip').assert_sibling('dd', text: billing_address_example_data[:postal_code])
    find('dt', text: 'City').assert_sibling('dd', text: billing_address_example_data[:locality])
    find('dt', text: 'State').assert_sibling('dd', text: billing_address_example_data[:region])
    find('dt', text: 'Country').assert_sibling('dd', text: billing_address_example_data[:country_name])
  end
end

# frozen_string_literal: true

Given "{buyer} has a valid credit card" do |buyer|
  buyer.update!(credit_card_partial_number: '1234',
                credit_card_expires_on_year: 2.years.from_now.year,
                credit_card_expires_on_month: 2.years.from_now.month,
                credit_card_auth_code: 'valid_code')
end

Given "{buyer} has a valid credit card with no money" do |buyer|
  # TODO: why is a credit card invalid and what does 'credit_card_auth_code' represent?
  buyer.update!(credit_card_expires_on_year: 2.years.from_now.year,
                credit_card_expires_on_month: 2.years.from_now.month,
                credit_card_auth_code: 'valid_if_ends_with_one_2')
end

When "the buyer is reviewing their account settings" do
  within 'header nav' do
    click_on 'Settings'
  end
end

When "the buyer is reviewing their credit card details" do
  visit admin_account_path
  click_on 'Credit Card Details'
end

Given "the buyer {has} added credit card details" do |details_present|
  # if details_present
  #   assert @buyer.has_billing_address? && @buyer.credit_card_stored?
  # else
  #   @buyer.update!(billing_address: {})
  # end

  if details_present
    PaymentGateways::BrainTreeBlueCrypt.any_instance.stubs(:customer_id_mismatch?).returns(false)
    PaymentGateways::BrainTreeBlueCrypt.any_instance.stubs(:find_customer).returns(nil)
    PaymentGateways::BrainTreeBlueCrypt.any_instance.stubs(:create_customer_data).returns(braintree_customer) # This skips sending post braintree API customers
    PaymentGateways::BrainTreeBlueCrypt.any_instance.stubs(:authorization).returns('mocked_authorization') # This skips sending post braintree API client_token
    PaymentGateways::BrainTreeBlueCrypt.any_instance.stubs(:confirm).returns(successful_braintree_result)
  else
    PaymentGateways::BrainTreeBlueCrypt.any_instance.stubs(:customer_id_mismatch?).returns(false)
    PaymentGateways::BrainTreeBlueCrypt.any_instance.stubs(:find_customer).returns(nil)
    PaymentGateways::BrainTreeBlueCrypt.any_instance.stubs(:create_customer_data).returns(nil) # This skips sending post braintree API customers
    PaymentGateways::BrainTreeBlueCrypt.any_instance.stubs(:authorization).returns('mocked_authorization') # This skips sending post braintree API client_token
    PaymentGateways::BrainTreeBlueCrypt.any_instance.stubs(:confirm).returns(nil)
  end
end

When "the buyer can add their credit card details" do
  within '#main-content .nav' do
    click_on 'Credit Card Details'
  end

  case @buyer.provider_account.payment_gateway_type
  when :braintree_blue
    click_on 'Add Credit Card Details and Billing Address'
    fill_braintree_payment_details_form
    click_on 'Save details'
    assert_flash 'CREDIT CARD DETAILS WERE SUCCESSFULLY STORED.'
    binding.pry
  when :stripe
    click_on 'Edit billing address'
    fill_stripe_payment_details_form
    click_on 'Save'
    assert_flash 'Your billing address was successfully stored'
  end

  assert_buyer_credit_card_details
end

When "the buyer can update their credit card details" do
  within '#main-content .nav' do
    click_on 'Credit Card Details'
  end

  case @buyer.provider_account.payment_gateway_type
  when :braintree_blue
    click_on 'Edit Credit Card Details and Billing Address'
    fill_braintree_payment_details_form
    click_on 'Save details'
    assert_flash 'CREDIT CARD DETAILS WERE SUCCESSFULLY STORED.'
  when :stripe
    click_on 'Edit billing address'
    fill_stripe_payment_details_form
    click_on 'Save'
    assert_flash 'Your billing address was successfully stored'
  end

  assert_buyer_credit_card_details
end

Then "the buyer can't add or update their credit card details" do
  assert_not has_xpath?(".//a[text()='Credit Card Details']")
  visit admin_account_payment_details_path
  assert_text 'Access Denied'
end

private

def fill_stripe_payment_details_form
  fill_in('Contact / Company Name', with: 'comp')
  fill_in('Address', with: 'C/LLacuna 162')
  fill_in('City', with: 'Barcelona')
  fill_in('ZIP / Postal Code', with: '08080')
  fill_in('Phone', with: '+34123123212')
  find_field('Country').find(:option, 'Spain').select_option
end

def assert_buyer_credit_card_details
  within '#billing_address' do
    find('dt', text: 'Address').assert_sibling('dd', text: customer_hash[:addresses].first[:street_address])
    find('dt', text: 'Zip').assert_sibling('dd', text: customer_hash[:addresses].first[:postal_code])
    find('dt', text: 'City').assert_sibling('dd', text: 'Barcelona')
    find('dt', text: 'State').assert_sibling('dd', text: 'Mali')
    find('dt', text: 'Country').assert_sibling('dd', text: 'Spain')
    find('dt', text: 'Phone').assert_sibling('dd', text: '+34123123212')
    find('dt', text: 'Credit card number').assert_sibling('dd', text: 'XXXX-XXXX-XXXX-1234')
    find('dt', text: 'Expiration date').assert_sibling('dd', text: 2.years.from_now.strftime('%B, %Y'))
  end
end

require 'test_helper'

class PaymentDetailsHelperTest < DeveloperPortal::ActionView::TestCase
  test '#payment_details_path' do
    account = Account.new(payment_gateway_type: :stripe)
    assert_equal '/admin/account/stripe?foo=bar&hello=world', payment_details_path(account, {foo: 'bar', hello: 'world'})
  end

  test '#edit_payment_details_path' do
    account = Account.new(payment_gateway_type: :stripe)
    assert_equal "#{@request.scheme}://#{@request.host}/admin/account/stripe/edit", edit_payment_details(account)
  end

  test '#stripe_billing_address_json' do
    billing_address = current_account.billing_address
    expected_response = {
      line1: billing_address.address1,
      line2: billing_address.address2,
      city: billing_address.city,
      state: billing_address.state,
      postal_code: billing_address.zip,
      country: billing_address.country
    }.to_json
    assert_equal expected_response, stripe_billing_address_json

    stubs(current_account: nil)
    assert_nil stripe_billing_address_json
  end

  private

  def current_account
    FactoryBot.build(:simple_account)
  end

  def logged_in?
    !!current_account
  end
end

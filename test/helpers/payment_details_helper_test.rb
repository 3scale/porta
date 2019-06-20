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
end

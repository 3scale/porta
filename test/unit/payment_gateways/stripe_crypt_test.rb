require 'test_helper'

class PaymentGateways::StripeCryptTest < ActiveSupport::TestCase
  def setup
    user = User.new
    @account = Account.new(org_name: 'The Company')
    attributes = {
      payment_gateway_type: :stripe,
      payment_gateway_options: {
        login: 'hello',
        password: 'world'
      }
    }
    @provider_account = FactoryGirl.build_stubbed(:simple_provider, attributes)
    @payment_gateway = @provider_account.payment_gateway

    @account.stubs(provider_account: @provider_account, id: 123)
    user.stubs(account: @account, email: 'user@example.com')

    @stripe = PaymentGateways::StripeCrypt.new(user)
  end

  test '#update!' do
    params = ActionController::Parameters.new({
      stripe: {
        token: 'stripe_card_token',
        expires_on_month: 1,
        expires_on_year: 2017,
        partial_number: 'XXXXXXXXX1234'
      }
    })

    customer = mock
    customer.expects(id: 'stripe_id')

    @account.expects(:credit_card_expires_on_month=).with(1)
    @account.expects(:credit_card_expires_on_year=).with(2017)
    @account.expects(:credit_card_auth_code=).with('stripe_id')
    @account.expects(:save)
    Stripe::Customer.expects(:create).with({
                                             card:        'stripe_card_token',
                                             description: 'The Company',
                                             email:       'user@example.com',
                                             metadata: {
                                               '3scale_account_reference' => PaymentGateways::BuyerReferences.buyer_reference(@account, @provider_account)
                                             }
                                           }, 'hello').returns(customer)
    @stripe.update!(params)
  end
end

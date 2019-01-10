require 'test_helper'

class Provider::Admin::Account::PaymentGateways::BraintreeBlueControllerTest < ActionDispatch::IntegrationTest
  include ActiveMerchantTestHelpers::BraintreeBlue
  def setup
    @provider = FactoryBot.create(:provider_account, credit_card_auth_code: 'foo')
    login_provider @provider
  end

  test 'delete destroy' do
    assert  @provider.credit_card_stored?
    ActiveMerchant::Billing::BogusGateway.any_instance.expects(:unstore)
    delete provider_admin_account_braintree_blue_path

    assert_response :redirect
    @provider.reload
    refute @provider.credit_card_stored?
  end

  test 'when finance is disabled for master' do
    login_provider master_account
    ThreeScale.config.stubs(onpremises: true)

    get provider_admin_account_braintree_blue_path
    assert_response :forbidden

    get edit_provider_admin_account_braintree_blue_path
    assert_response :forbidden

    get hosted_success_provider_admin_account_braintree_blue_path
    assert_response :forbidden

    put provider_admin_account_braintree_blue_path
    assert_response :forbidden

    delete provider_admin_account_braintree_blue_path
    assert_response :forbidden

  end

  test 'when on premises for provider' do
    ThreeScale.config.stubs(onpremises: true)

    get provider_admin_account_braintree_blue_path
    assert_response :forbidden

    get edit_provider_admin_account_braintree_blue_path
    assert_response :forbidden

    get hosted_success_provider_admin_account_braintree_blue_path
    assert_response :forbidden

    put provider_admin_account_braintree_blue_path
    assert_response :forbidden

    delete provider_admin_account_braintree_blue_path
    assert_response :forbidden

  end

  test 'invalid credentials' do
    ThreeScale.config.stubs(onpremises: false)

    payment_gateway_options = {
      environment: :sandbox,
      merchant_id: 'incorrect',
      public_key: 'also-incorrect',
      private_key: 'yeah-it-is-a-mess'
    }
    master_account.update_attributes(payment_gateway_options: payment_gateway_options)
    @provider.update_attributes(state_region: 'State', city: 'City', zip: '1234')

    ::PaymentGateways::BrainTreeBlueCrypt.any_instance.stubs(:try_find_customer).raises(Braintree::AuthenticationError)
    get edit_provider_admin_account_braintree_blue_path
    assert_redirected_to provider_admin_account_braintree_blue_path
    assert_equal 'Invalid merchant id', flash[:error]
  end

  test 'missing credentials' do
    ThreeScale.config.stubs(onpremises: false)

    @provider.update_attributes(state_region: 'State', city: 'City', zip: '1234')

    get edit_provider_admin_account_braintree_blue_path
    assert_redirected_to provider_admin_account_braintree_blue_path
    assert_equal 'Invalid merchant id', flash[:error]
  end
end

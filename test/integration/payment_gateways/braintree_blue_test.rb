require 'test_helper'

class BraintreeBlueTest < ActionDispatch::IntegrationTest
  def setup
    @provider_account, plan = create_provider_account

    @provider_account.settings.allow_finance! unless @provider_account.settings.finance.allowed?
    @provider_account.settings.show_finance! unless @provider_account.settings.finance.visible?

    @buyer_account = FactoryBot.create(:buyer_account, :provider_account => @provider_account)
    @buyer_account.buy!(plan)
    host! @provider_account.internal_domain
  end

  test "navigate to the correct link" do
    login_with @buyer_account.admins.first.username, 'superSecret1234#'

    get "/admin/account/"
    details_url = "/admin/account/braintree_blue"
    assert_select('a[href=?]', details_url)
  end

  test "credit card stored ok" do
    # stub BrainTreeBlueCrypt.new(current_user).confirm(request) to return struct that answers true to success
    @provider_account.payment_gateway_options[:environment] = :sandbox
    @provider_account.payment_gateway_options[:merchant_id] = "my-payment-gw-mid"
    @provider_account.payment_gateway_options[:public_key] = "AnY-pUbLiC-kEy"
    @provider_account.payment_gateway_options[:private_key] = "a1b2c3d4e5"

    assert_nil @buyer_account.credit_card_partial_number
  end

  test "credit card not stored" do
    # stub BrainTreeBlueCrypt.new(current_user).confirm(request) to return struct that answers false to success
    login_with @buyer_account.admins.first.username, 'superSecret1234#'
    PaymentGateways::BrainTreeBlueCrypt.any_instance.stubs(:confirm).returns(false)
    get "/admin/account/braintree_blue/hosted_success"
  end

  test "bad credentials" do
    # stub BrainTreeBlueCrypt.new(current_user).confirm(request) to return nil
    PaymentGateways::BrainTreeBlueCrypt.any_instance.stubs(:confirm).returns(nil)
  end

  test "invalid merchant id redirects to show" do
    PaymentGateways::BrainTreeBlueCrypt.any_instance.stubs(:try_find_customer).raises(Braintree::AuthenticationError)
    login_buyer @buyer_account
    get developer_portal.edit_admin_account_braintree_blue_path
    assert_redirected_to developer_portal.admin_account_braintree_blue_path
    assert_equal 'Invalid merchant id', flash[:error]
  end

  def create_provider_account
    provider_account = FactoryBot.create(:provider_with_billing, :payment_gateway_type => :braintree_blue, :payment_gateway_options => {:merchant_id => 'foo', :public_key => 'bar', :private_key => 'baz'})
    provider_account.billing_strategy = FactoryBot.create(:postpaid_with_charging)
    provider_account.payment_gateway_type = :braintree_blue

    plan = FactoryBot.create(:application_plan, :issuer => provider_account.default_service)
    [provider_account, plan]
  end
end

require 'test_helper'

class Finance::Provider::SettingsControllerTest < ActionController::TestCase

  def setup
    @provider = FactoryBot.create(:provider_account, :billing_strategy => FactoryBot.create(:postpaid_with_charging))
    @provider.settings.allow_finance!
    host! @provider.external_admin_domain
  end

  test 'login is required' do
    get :show
    assert_redirected_to provider_login_url
  end

  test 'show' do
    @provider.payment_gateway_type = :stripe
    @provider.save!

    gateway = PaymentGateway::GATEWAYS.find { |g| g.type == :stripe }

    PaymentGateway.stubs(:all).returns([gateway])
    login_as(@provider.admins.first)
    get :show

    assert_response :success
    # assert_template 'admin/account/payment_gateways/show'

    # assert_active_menu(:account)
    assert_equal @provider, assigns(:account)
    assert_equal [gateway], assigns(:payment_gateways)

    assert_select_form admin_account_payment_gateway_path, :method => :patch do
      assert_select 'select[name=?]', 'account[payment_gateway_type]'
      assert_select 'button[type=submit]'

      assert_select 'input[type=text][name=?]', 'account[payment_gateway_options][login]'
      assert_select 'input[type=text][name=?]', 'account[payment_gateway_options][publishable_key]'
      assert_select 'input[type=text][name=?]', 'account[payment_gateway_options][endpoint_secret]'
    end
  end

  test 'gateways options should contain only the supported gateways' do
    PaymentGateway.stubs(:all).returns(payment_gateways)

    @provider.gateway_setting.update(gateway_type: :supported_gateway)

    login_as(@provider.admins.first)
    get :show

    assert_response :success
    page = Nokogiri::HTML4::Document.parse(response.body)

    values = page.xpath(".//select[@id='account_payment_gateway_type']/*").map { |o| o['value'] }

    assert_equal(['', 'supported_gateway'], values)
  end

  test 'gateways options should contain deprecated gateway if in use' do
    PaymentGateway.stubs(:all).returns(payment_gateways)

    @provider.gateway_setting.gateway_type = :deprecated_gateway
    @provider.gateway_setting.save(validate: false)

    login_as(@provider.admins.first)
    get :show

    assert_response :success
    page = Nokogiri::HTML4::Document.parse(response.body)

    values = page.xpath(".//select[@id='account_payment_gateway_type']/*").map { |o| o['value'] }

    assert_same_elements(['', 'supported_gateway', 'deprecated_gateway'], values)
  end

  def payment_gateways
    supported_gateway = PaymentGateway.new(:supported_gateway, deprecated: false, foo: 'Bar')
    supported_gateway.stubs(:display_name).returns('Supported Payment Gateway')
    supported_gateway.stubs(:homepage_url).returns('')

    deprecated_gateway = PaymentGateway.new(:deprecated_gateway, deprecated: true, foo: 'Bar')
    deprecated_gateway.stubs(:display_name).returns('Deprecated Payment Gateway')
    deprecated_gateway.stubs(:homepage_url).returns('')

    [supported_gateway, deprecated_gateway]
  end
end

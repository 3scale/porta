require 'test_helper'

class Finance::Provider::SettingsControllerTest < ActionController::TestCase

  def setup
    @provider = FactoryBot.create(:provider_account, :billing_strategy => FactoryBot.create(:postpaid_with_charging))
    @provider.settings.allow_finance!
    @request.host = @provider.admin_domain
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

  context 'gateways options' do
    should 'contain only the supported gateways' do
      login_as(@provider.admins.first)
      get :show

      assert_response :success
      page = Nokogiri::HTML::Document.parse(response.body)

      values = page.xpath(".//select[@id='account_payment_gateway_type']/*").map { |o| o['value'] }

      assert_equal(['', 'braintree_blue', 'stripe', 'bogus'], values)
    end

    should 'contain deprecated gateway if in use' do
      @provider.gateway_setting.gateway_type = :ogone
      @provider.gateway_setting.save(validate: false)

      login_as(@provider.admins.first)
      get :show

      assert_response :success
      page = Nokogiri::HTML::Document.parse(response.body)

      values = page.xpath(".//select[@id='account_payment_gateway_type']/*").map { |o| o['value'] }

      assert_same_elements(['', 'braintree_blue', 'ogone', 'stripe', 'bogus'], values)
    end
  end # gateway options
end

# frozen_string_literal: true

require 'test_helper'

class Admin::Account::PaymentGatewaysControllerTest < ActionDispatch::IntegrationTest

  def setup
    @provider = FactoryBot.create(:provider_account, :billing_strategy => FactoryBot.create(:postpaid_with_charging))
    @provider.settings.allow_finance!

    login! @provider
  end

  test 'update' do
    put admin_account_payment_gateway_path(@provider), params: { account: {
      payment_gateway_type: 'stripe',
      payment_gateway_options: { 'login' => 'bob', 'publishable_key' => 'monkey', 'endpoint_secret' => 'some-secret' }
    } }

    @provider.reload
    @provider.gateway_setting.reload
    assert_redirected_to admin_finance_settings_url
    assert_equal 'Payment gateway details were successfully saved.', flash[:notice]
    assert_equal({
                   'gateway_type' => 'stripe',
                   'gateway_settings' => {
                     'login' => 'bob', 'publishable_key' => 'monkey', 'endpoint_secret' => 'some-secret'
                   }
                 },
                 @provider.gateway_setting.attributes.slice('gateway_type', 'gateway_settings'))
  end

  test 'cannot set a deprecated payment gateway' do
    assert_raises ActiveRecord::RecordInvalid do
      @provider.gateway_setting.gateway_type = :stripe
      @provider.gateway_setting.save(validate: false)

      deprecated_gateway = PaymentGateway.new(:bogus, deprecated: true, foo: 'Foo')
      PaymentGateway.stubs(all: [deprecated_gateway])

      put admin_account_payment_gateway_path(@provider), params: { account: {
        payment_gateway_type: 'bogus',
        payment_gateway_options: { foo: :bar }
      } }
    end
  end

  test 'can switch from a deprecated payment gateway' do
    deprecated_gateway = PaymentGateway.new(:bogus, deprecated: true, foo: 'Foo')
    PaymentGateway.stubs(all: [deprecated_gateway, PaymentGateway.find(:stripe)])

    @provider.gateway_setting.gateway_type = :bogus
    @provider.gateway_setting.save(validate: false)

    put admin_account_payment_gateway_path(@provider), params: { account: {
      payment_gateway_type: 'stripe',
      payment_gateway_options: { 'login' => 'bob', 'publishable_key' => 'monkey', 'endpoint_secret' => 'some-secret' }
    } }

    @provider.reload
    @provider.gateway_setting.reload
    assert_redirected_to admin_finance_settings_url
    assert_equal 'Payment gateway details were successfully saved.', flash[:notice]
    assert_equal(
      { 'gateway_type' => 'stripe', 'gateway_settings' => { 'login' => 'bob', 'publishable_key' => 'monkey', 'endpoint_secret' => 'some-secret'} },
      @provider.gateway_setting.attributes.slice('gateway_type', 'gateway_settings')
    )
  end

  test 'can update options of a deprecated payment gateway' do
    @provider.gateway_setting.gateway_type = :bogus
    @provider.gateway_setting.save(validate: false)

    deprecated_gateway = PaymentGateway.new(:bogus, deprecated: true, foo: 'Foo')
    PaymentGateway.stubs(all: [deprecated_gateway])

    put admin_account_payment_gateway_path(@provider), params: { account: {
      payment_gateway_type: 'bogus',
      payment_gateway_options: { foo: :baz }
    } }

    @provider.reload
    @provider.gateway_setting.reload
    assert_redirected_to admin_finance_settings_url
    assert_equal 'Payment gateway details were successfully saved.', flash[:notice]
    assert_equal(
      { 'gateway_type' => 'bogus', 'gateway_settings' => { 'foo' => 'baz' } },
      @provider.gateway_setting.attributes.slice('gateway_type', 'gateway_settings')
    )
  end
end

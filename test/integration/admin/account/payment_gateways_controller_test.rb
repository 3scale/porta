# frozen_string_literal: true

require 'test_helper'

class Admin::Account::PaymentGatewaysControllerTest < ActionDispatch::IntegrationTest

  def setup
    @provider = FactoryBot.create(:provider_account, billing_strategy: FactoryBot.create(:postpaid_with_charging))
    @provider.settings.allow_finance!

    login! @provider
  end

  attr_reader :provider

  delegate :gateway_setting, to: :provider
  delegate :attributes, to: :gateway_setting

  test 'update' do
    put admin_account_payment_gateway_path(provider), params: { account: {
      payment_gateway_type: 'stripe',
      payment_gateway_options: gateway_options
    } }

    provider.reload
    provider.gateway_setting.reload
    assert_redirected_to admin_finance_settings_url
    assert_equal 'Payment gateway details were successfully saved.', flash[:notice]
    assert_equal attributes['gateway_type'], 'stripe'
    assert_equal attributes['gateway_settings'], ActionController::Parameters.new(gateway_options)
  end

  test 'cannot set a deprecated payment gateway' do
    assert_raises ActiveRecord::RecordInvalid do
      provider.gateway_setting.gateway_type = :stripe
      provider.gateway_setting.save(validate: false)

      deprecated_gateway = PaymentGateway.new(:bogus, deprecated: true, foo: 'Foo')
      PaymentGateway.stubs(all: [deprecated_gateway])

      put admin_account_payment_gateway_path(provider), params: { account: {
        payment_gateway_type: 'bogus',
        payment_gateway_options: gateway_options
      } }
    end
  end

  test 'can switch from a deprecated payment gateway' do
    deprecated_gateway = PaymentGateway.new(:bogus, deprecated: true, foo: 'Foo')
    PaymentGateway.stubs(all: [deprecated_gateway, PaymentGateway.find(:stripe)])

    provider.gateway_setting.gateway_type = :bogus
    provider.gateway_setting.save(validate: false)

    put admin_account_payment_gateway_path(provider), params: { account: {
      payment_gateway_type: 'stripe',
      payment_gateway_options: gateway_options
    } }

    provider.reload
    provider.gateway_setting.reload
    assert_redirected_to admin_finance_settings_url
    assert_equal 'Payment gateway details were successfully saved.', flash[:notice]
    assert_equal attributes['gateway_type'], 'stripe'
    assert_equal attributes['gateway_settings'], ActionController::Parameters.new(gateway_options)
  end

  test 'can update options of a deprecated payment gateway' do
    provider.gateway_setting.gateway_type = :bogus
    provider.gateway_setting.save(validate: false)

    deprecated_gateway = PaymentGateway.new(:bogus, deprecated: true, foo: 'Foo')
    PaymentGateway.stubs(all: [deprecated_gateway])

    put admin_account_payment_gateway_path(provider), params: { account: {
      payment_gateway_type: 'bogus',
      payment_gateway_options: gateway_options
    } }

    provider.reload
    provider.gateway_setting.reload
    assert_redirected_to admin_finance_settings_url
    assert_equal 'Payment gateway details were successfully saved.', flash[:notice]
    assert_equal attributes['gateway_type'], 'bogus'
    assert_equal attributes['gateway_settings'], ActionController::Parameters.new(gateway_options)
  end

  private

  def gateway_options
    { 'login' => 'bob', 'publishable_key' => 'monkey', 'endpoint_secret' => 'some-secret' }
  end
end

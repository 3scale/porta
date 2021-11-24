# frozen_string_literal: true

require 'test_helper'

# TODO: will become a CreditCard model by itself soon
class Account::GatewayTest  < ActiveSupport::TestCase

  test 'serializes payment_gateway_options' do
    account = FactoryBot.create(:simple_account, :payment_gateway_options => {:foo => 'bar'})
    account.reload

    assert_equal 'bar', account.payment_gateway_options[:foo]
  end

  test 'symbolizes keys of payment_gateway_options' do
    account = FactoryBot.create(:simple_account, :payment_gateway_options => {'foo' => 'bar'})
    account.reload

    assert_equal 'bar', account.payment_gateway_options[:foo]
    assert_nil          account.payment_gateway_options['foo']
  end

  test 'payment_gateway should be nil by default' do
    account = FactoryBot.create(:simple_account)
    assert_nil account.payment_gateway
  end

  test 'payment_gateway should return active merchant gateway according to type and options' do
    account = FactoryBot.create(:simple_account, :payment_gateway_type => :braintree_blue,
                      :payment_gateway_options => {:public_key => 'foo',
                        :merchant_id => 'bar',
                        :private_key => 'pkey'})

    assert_not_nil account.payment_gateway
    assert_instance_of ActiveMerchant::Billing::BraintreeBlueGateway, account.payment_gateway
    assert_equal 'foo', account.payment_gateway.options[:public_key]
    assert_equal 'bar', account.payment_gateway.options[:merchant_id]
    assert_equal 'pkey', account.payment_gateway.options[:private_key]
  end

  test '#payment_gateway_setting does not save empty settings' do
    skip 'See Account::Gateway#find_gateway_setting for more explanation'
    account = FactoryBot.create(:simple_account)
    account.gateway_setting
    account.save!
    assert_not account.gateway_setting.persisted?, "payment gateway settings must not be saved"
  end

  test '#payment_gateway_type is saved in `payment_gateway_setting association' do
    account = FactoryBot.create(:simple_account)

    gateway_setting = account.gateway_setting
    assert gateway_setting.new_record?

    account.payment_gateway_type = :stripe
    account.save!
    assert gateway_setting.persisted?

    gateway_setting.reload
    assert_equal :stripe, gateway_setting.gateway_type
  end

  test '#payment_gateway_options is saved in `payment_gateway_setting association' do
    account = FactoryBot.create(:simple_account)
    gateway_setting = account.gateway_setting

    account.payment_gateway_options = {hello: 'world'}
    account.save!
    gateway_setting.reload

    assert_equal({hello: 'world'}, account.payment_gateway_options)
  end

  test '#payment_gateway_options is not returning :test' do
    account = FactoryBot.create(:simple_account, payment_gateway_options: {foo: 'bar', test: '1'})
    gateway_setting = account.gateway_setting

    assert_not gateway_setting.symbolized_settings.key?(:test)

    assert_equal({foo: 'bar'}, account.payment_gateway_options)
  end

  test '#payment_gateway_configured?' do
    account = FactoryBot.create(:simple_account)
    account.gateway_setting.save!

    account.gateway_setting.stubs(configured?: false)

    assert_not account.payment_gateway_configured?

    account.gateway_setting.stubs(configured?: true)

    assert account.payment_gateway_configured?
  end

  test 'payment_gateway' do
    provider = Account.new

    provider.payment_gateway_type = nil
    assert_nil provider.payment_gateway

    provider.payment_gateway_type    = :braintree_blue
    provider.payment_gateway_options = {merchant_id: 'foo', public_key: 'bar', private_key: 'baz'}
    assert_instance_of ActiveMerchant::Billing::BraintreeBlueGateway, provider.payment_gateway
    assert_equal provider.payment_gateway_options,                    provider.payment_gateway.options

    provider.payment_gateway_type    = :stripe
    provider.payment_gateway_options = { login: 'sk_test_4eC39HqLyjWDarjtT1zdp7dc', publishable_key: 'pk_test_TYooMQauvdEDq54NiTphI7jx', endpoint_secret: 'some-secret' }
    assert_instance_of ActiveMerchant::Billing::StripeGateway, provider.payment_gateway
    assert_not_instance_of ActiveMerchant::Billing::StripePaymentIntentsGateway, provider.payment_gateway # this test is necessary because StripePaymentIntentsGateway is a subclass of StripeGateway
    assert_equal provider.payment_gateway_options, provider.payment_gateway.options
    assert_instance_of ActiveMerchant::Billing::StripePaymentIntentsGateway, provider.payment_gateway(sca: true)
    assert_equal provider.payment_gateway_options, provider.payment_gateway(sca: true).options
  end

  test 'provider_payment_gateway' do
    buyer = Account.new

    assert_nil buyer.provider_payment_gateway

    buyer.provider_account = Account.new

    assert_nil buyer.provider_payment_gateway

    buyer.provider_account.payment_gateway_type = :braintree_blue
    buyer.provider_account.payment_gateway_options = {merchant_id: 'foo', public_key: 'bar', private_key: 'baz'}
    assert_instance_of ActiveMerchant::Billing::BraintreeBlueGateway, buyer.provider_payment_gateway

    buyer.provider_account.payment_gateway_type = :stripe
    buyer.provider_account.payment_gateway_options = { login: 'sk_test_4eC39HqLyjWDarjtT1zdp7dc', publishable_key: 'pk_test_TYooMQauvdEDq54NiTphI7jx', endpoint_secret: 'some-secret' }
    assert_instance_of ActiveMerchant::Billing::StripeGateway, buyer.provider_payment_gateway
    assert_not_instance_of ActiveMerchant::Billing::StripePaymentIntentsGateway, buyer.provider_payment_gateway # this test is necessary because StripePaymentIntentsGateway is a subclass of StripeGateway
    buyer.payment_detail.payment_method_id = 'pm_1I5s3n2eZvKYlo2CiO193T69'
    assert_instance_of ActiveMerchant::Billing::StripePaymentIntentsGateway, buyer.provider_payment_gateway
  end
end

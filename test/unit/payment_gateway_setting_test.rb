require 'test_helper'

class PaymentGatewaySettingTest < ActiveSupport::TestCase
  def setup
    @gateway_setting = PaymentGatewaySetting.new
  end

  test '#configured? failed if gateway_type blank' do
    assert @gateway_setting.gateway_type.blank?

    refute @gateway_setting.configured?
  end

  test '#configured? failed if any gateway_settings missing for authorize_net' do
    @gateway_setting.gateway_type = :authorize_net
    @gateway_setting.gateway_settings = {login: '1234'}
    refute @gateway_setting.configured?

    @gateway_setting.gateway_settings[:password] = '56789'
    assert @gateway_setting.configured?
  end

  test '#configured? failed if any gateway_settings missing for braintree_blue' do
    @gateway_setting.gateway_type = :braintree_blue
    @gateway_setting.gateway_settings = { public_key: '', merchant_id: 'Merchant ID', private_key: 'Private Key'}
    refute @gateway_setting.configured?

    @gateway_setting.gateway_settings[:public_key] = 'PUBKEY'
    assert @gateway_setting.configured?
  end

  test '#configured? failed if any gateway_settings missing for stripe' do
    @gateway_setting.gateway_type = :stripe
    @gateway_setting.gateway_settings = { login: 'Secret Key', publishable_key: '', endpoint_secret: 'some-secret' }
    refute @gateway_setting.configured?

    @gateway_setting.gateway_settings[:publishable_key] = 'PUBKEY'
    assert @gateway_setting.configured?
  end

  test 'cannot create with a deprecated payment gateway' do
    deprecated_gateway = PaymentGateway.new(:bogus, deprecated: true, field_a: 'A', field_b: 'B')
    PaymentGateway.stubs(all: [deprecated_gateway])

    @gateway_setting.gateway_type = :bogus
    @gateway_setting.gateway_settings = { field_a: 'my-config-a', field_b: 'my-config-b' }

    refute @gateway_setting.valid?
    assert @gateway_setting.errors.added?(:gateway_type, :invalid)
  end

  test 'cannot switch to a deprecated payment gateway' do
    gateway_setting = FactoryBot.create(:payment_gateway_setting, gateway_type: :stripe)

    deprecated_gateway = PaymentGateway.new(:bogus, deprecated: true, field_a: 'A', field_b: 'B')
    PaymentGateway.stubs(all: [deprecated_gateway])

    gateway_setting.gateway_type = :bogus
    gateway_setting.gateway_settings = { field_a: 'my-config-a', field_b: 'my-config-b' }

    refute gateway_setting.valid?
    assert gateway_setting.errors.added?(:gateway_type, :invalid)
  end

  test 'can switch from deprecated payment gateway' do
    deprecated_gateway = PaymentGateway.new(:bogus, deprecated: true, foo: 'Foo')
    PaymentGateway.stubs(all: [deprecated_gateway, PaymentGateway.find(:stripe)])

    gateway_setting = FactoryBot.build(:payment_gateway_setting, gateway_type: :bogus, gateway_settings: { foo: :bar })
    gateway_setting.save(validate: false)

    gateway_setting.gateway_type = :stripe
    gateway_setting.gateway_settings = { login: 'Secret Key', publishable_key: '', endpoint_secret: 'some-secret' }

    assert gateway_setting.valid?
    refute gateway_setting.errors.added?(:gateway_type, :invalid)
  end

  test 'can update deprecated payment gateway in use' do
    gateway_setting = FactoryBot.build(:payment_gateway_setting, gateway_type: :bogus, gateway_settings: { foo: :bar })
    gateway_setting.save(validate: false)

    deprecated_gateway = PaymentGateway.new(:bogus, deprecated: true, field_a: 'A', field_b: 'B')
    PaymentGateway.stubs(all: [deprecated_gateway])

    gateway_setting.gateway_type = :bogus
    gateway_setting.gateway_settings = { foo: :baz }

    assert gateway_setting.valid?
    refute gateway_setting.errors.added?(:gateway_type, :invalid)
  end

  test 'with boolean fields' do
    @gateway_setting.gateway_type = :braintree_blue
    @gateway_setting.gateway_settings = { public_key: 'Public Key', merchant_id: 'Merchant ID', private_key: 'Private Key'}
    assert @gateway_setting.configured?

    refute @gateway_setting.gateway_settings[:three_ds_enabled], 'three_ds_enabled should be falsey'

    @gateway_setting.gateway_settings = { public_key: 'Public Key', merchant_id: 'Merchant ID', private_key: 'Private Key', three_ds_enabled: true}
    assert @gateway_setting.gateway_settings[:three_ds_enabled], 'three_ds_enabled should be truthy'
  end
end

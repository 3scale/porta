require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

# TODO: will become a CreditCard model by itself soon
class Account::GatewayTest  < ActiveSupport::TestCase

  test 'serializes payment_gateway_options' do
    account = FactoryGirl.create(:simple_account, :payment_gateway_options => {:foo => 'bar'})
    account.reload

    assert_equal 'bar', account.payment_gateway_options[:foo]
  end

  test 'symbolizes keys of payment_gateway_options' do
    account = FactoryGirl.create(:simple_account, :payment_gateway_options => {'foo' => 'bar'})
    account.reload

    assert_equal 'bar', account.payment_gateway_options[:foo]
    assert_nil          account.payment_gateway_options['foo']
  end

  context 'payment_gateway' do
    should 'be nil by default' do
      account = FactoryGirl.create(:simple_account)
      assert_nil account.payment_gateway
    end

    should 'return active merchant gateway according to type and options' do
      account = FactoryGirl.create(:simple_account, :payment_gateway_type => :braintree_blue,
                        :payment_gateway_options => {:public_key => 'foo',
                          :merchant_id => 'bar',
                          :private_key => 'pkey'})

      assert_not_nil account.payment_gateway
      assert_instance_of ActiveMerchant::Billing::BraintreeBlueGateway, account.payment_gateway
      assert_equal 'foo', account.payment_gateway.options[:public_key]
      assert_equal 'bar', account.payment_gateway.options[:merchant_id]
      assert_equal 'pkey', account.payment_gateway.options[:private_key]
    end
  end

  test '#payment_gateway_setting does not save empty settings' do
    skip 'See Account::Gateway#find_gateway_setting for more explanation'
    account = FactoryGirl.create(:simple_account)
    account.gateway_setting
    account.save!
    refute account.gateway_setting.persisted?, "payment gateway settings must not be saved"
  end

  test '#payment_gateway_type is saved in `payment_gateway_setting association' do
    account = FactoryGirl.create(:simple_account)

    gateway_setting = account.gateway_setting
    assert gateway_setting.new_record?

    account.payment_gateway_type = :stripe
    account.save!
    assert gateway_setting.persisted?

    gateway_setting.reload
    assert_equal :stripe, gateway_setting.gateway_type
  end

  test '#payment_gateway_options is saved in `payment_gateway_setting association' do
    account = FactoryGirl.create(:simple_account)
    gateway_setting = account.gateway_setting

    account.payment_gateway_options = {hello: 'world'}
    account.save!
    gateway_setting.reload

    assert_equal({hello: 'world'}, account.payment_gateway_options)
  end

  test '#payment_gateway_options is not returning :test' do
    account = FactoryGirl.create(:simple_account, payment_gateway_options: {foo: 'bar', test: '1'})
    gateway_setting = account.gateway_setting

    refute  gateway_setting.symbolized_settings.has_key?(:test)

    assert_equal({foo: 'bar'}, account.payment_gateway_options)
  end

  test '#payment_gateway_configured?' do

    account = FactoryGirl.create(:simple_account)
    account.gateway_setting.save!

    account.gateway_setting.stubs(configured?: false)

    refute account.payment_gateway_configured?
    assert account.payment_gateway_unconfigured?

    account.gateway_setting.stubs(configured?: true)

    assert account.payment_gateway_configured?
    refute account.payment_gateway_unconfigured?

  end

end

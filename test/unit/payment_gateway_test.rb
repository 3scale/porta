# frozen_string_literal: true

require 'test_helper'

class PaymentGatewayTest < ActiveSupport::TestCase
  setup do
    @gateway = PaymentGateway::GATEWAYS.detect {|n| n.type == type }
  end

  attr_reader :gateway

  class ClassMethodsTest < ActiveSupport::TestCase
    test '#all contain only supported gateways' do
      PaymentGateway.stubs(:bogus_enabled?).returns(false)
      assert_equal %i[authorize_net braintree_blue ogone stripe], PaymentGateway.all.map(&:type).sort
    end

    test '#all include bogus when enabled' do
      PaymentGateway.stubs(:bogus_enabled?).returns(true)
      assert_includes PaymentGateway.all.map(&:type), :bogus
    end

    test '#non_boolean_fields' do
      payment_gateway = PaymentGateway.new(:feature, name: 'Name of the feature', opt_in: 'Opt in', boolean: %i[opt_in])
      assert_equal %i[opt_in], payment_gateway.boolean_field_keys
      assert_equal ({ name: 'Name of the feature' }), payment_gateway.non_boolean_fields
    end
  end

  class AuthorizeNetTest < PaymentGatewayTest
    def type
      :authorize_net
    end

    test 'have display_name' do
      assert_equal 'Authorize.Net', gateway.display_name
    end

    test 'have homepage_url' do
      assert_equal 'http://www.authorize.net/', gateway.homepage_url
    end

    test ':login and :password order in #fields' do
      fields = gateway.fields.keys

      assert_equal 0, fields.index(:login), ":login must be the first field declared in Gateway[#{type}]"
      assert_equal 1, fields.index(:password), ":password must be the second field declared in Gateway[#{type}]"
    end
  end

  class BraintreeBlueTest < PaymentGatewayTest
    def type
      :braintree_blue
    end

    test 'have display_name' do
      assert_equal 'Braintree (Blue Platform)', gateway.display_name
    end

    test 'have homepage_url' do
      assert_equal 'http://www.braintreepaymentsolutions.com', gateway.homepage_url
    end

    test ':login and :password order in #fields' do
      assert_not_includes gateway.fields.keys, %i[login password], ":login and :password must not be fields declared in Gateway[#{type}]"
    end
  end

  class OgoneTest < PaymentGatewayTest
    def type
      :ogone
    end

    test 'have display_name' do
      assert_equal 'Ogone', gateway.display_name
    end

    test 'have homepage_url' do
      assert_equal 'http://www.ogone.com/', gateway.homepage_url
    end

    test ':login and :password order in #fields' do
      assert_not_includes gateway.fields.keys, %i[login password], ":login and :password must not be a field declared in Gateway[#{type}]"
    end
  end

  class StripeTest < PaymentGatewayTest
    def type
      :stripe
    end

    test 'have display_name' do
      assert_equal 'Stripe', gateway.display_name
    end

    test 'have homepage_url' do
      assert_equal 'https://stripe.com/', gateway.homepage_url
    end

    test ':login and :password order in #fields' do
      fields = gateway.fields.keys

      assert_equal 0, fields.index(:login), ":login must be the first field declared in Gateway[#{type}]"
      assert_not_includes fields, :password, ":password must not be the a field declared in Gateway[#{type}]"
    end

    test '#implementation with and without SCA' do
      assert_equal ActiveMerchant::Billing::StripeGateway,               PaymentGateway.implementation(type)
      assert_equal ActiveMerchant::Billing::StripePaymentIntentsGateway, PaymentGateway.implementation(type, sca: true)
    end
  end

  test '#find' do
    assert_not_nil PaymentGateway.find(type)
  end

  def self.runnable_methods
    return [] if self == PaymentGatewayTest

    super
  end
end

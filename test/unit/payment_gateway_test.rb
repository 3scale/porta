# frozen_string_literal: true

require 'test_helper'

class PaymentGatewayTest < ActiveSupport::TestCase
  test 'have display_name' do
    assert_equal 'Authorize.Net', PaymentGateway.new(:authorize_net).display_name
  end

  test 'have homepage_url' do
    assert_equal 'http://www.authorize.net/', PaymentGateway.new(:authorize_net).homepage_url
  end

  test 'method #all contain only supported gateways' do
    PaymentGateway.stubs(:bogus_enabled?).returns(false)
    assert_equal %i[authorize_net braintree_blue ogone stripe], PaymentGateway.all.map(&:type).sort
  end

  test 'method #all include bogus when enabled' do
    PaymentGateway.stubs(:bogus_enabled?).returns(true)
    assert_includes PaymentGateway.all.map(&:type), :bogus
  end

  test ':login and :password order in #fields' do
    PaymentGateway::GATEWAYS.each do |gateway|
      fields = gateway.fields.keys

      assert [nil, 0].include?(fields.index(:login)), ":login must be the first field declared in Gateway[#{gateway.type}]"
      if gateway.fields.keys.index(:login)
        assert [nil, 1].include?(fields.index(:password)), ":password must be the second field declared in Gateway[#{gateway.type}]"
      else
        assert [nil, 0].include?(fields.index(:password)), ":password must be the first field declared in Gateway[#{gateway.type}]"
      end
    end
  end

  test '::find' do
    PaymentGateway.types.each do |type|
      assert_not_nil PaymentGateway.find(type)
    end
  end

  test '.implementation for stripe with and without SCA' do
    assert_equal ActiveMerchant::Billing::StripeGateway,               PaymentGateway.implementation(:stripe)
    assert_equal ActiveMerchant::Billing::StripePaymentIntentsGateway, PaymentGateway.implementation(:stripe, sca: true)
  end

  test 'non_boolean_fields' do
    payment_gateway = PaymentGateway.new(:feature, name: 'Name of the feature', opt_in: 'Opt in', boolean: %i[opt_in])
    assert_equal %i[opt_in], payment_gateway.boolean_field_keys
    assert_equal({name: 'Name of the feature'}, payment_gateway.non_boolean_fields)
  end
end

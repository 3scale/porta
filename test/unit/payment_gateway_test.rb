require 'test_helper'

class PaymentGatewayTest < ActiveSupport::TestCase

  should 'have display_name' do
    assert_equal 'Authorize.Net', PaymentGateway.new(:authorize_net).display_name
  end

  should 'have homepage_url' do
    assert_equal 'http://www.authorize.net/', PaymentGateway.new(:authorize_net).homepage_url
  end

  context 'method #all' do
    setup { PaymentGateway.stubs(:bogus_enabled?).returns(false) }

    should 'contain only supported gateways' do
      assert_equal [:adyen12, :authorize_net, :braintree_blue, :ogone, :stripe], PaymentGateway.all.map(&:type).sort
    end

    should 'include bogus when enabled' do
      PaymentGateway.stubs(:bogus_enabled?).returns(true)
      assert_includes PaymentGateway.all.map(&:type), :bogus
    end
  end # method #all

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
end

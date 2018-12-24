require 'test_helper'

module PaymentGateways
  class PaymentGatewayCryptTest < ActiveSupport::TestCase

    def setup
      @user = mock
      @provider_account = FactoryBot.build_stubbed(:simple_provider)
      @account = FactoryBot.build_stubbed(:simple_account)
      @account.stubs(provider_account: @provider_account)
      @user.stubs(account: @account, email: 'user@example.com')
      @gateway = PaymentGateways::PaymentGatewayCrypt.new(@user)
    end

    test '#test? inherits from Active Merchant mode' do
      ActiveMerchant::Billing::Base.stubs(:mode).returns(:test)
      assert @gateway.test?

      ActiveMerchant::Billing::Base.stubs(:mode).returns(:production)
      refute @gateway.test?
    end

    test 'attribute readers' do
      assert_equal @user, @gateway.user
      assert_equal @account, @gateway.account
      assert_equal @provider_account, @gateway.provider
    end

  end
end

require 'test_helper'

module PaymentGateways
  class OgoneCryptTest < ActiveSupport::TestCase

    def setup
      @user = mock
      @account = mock
      attributes = {
        payment_gateway_type: :ogone,
        payment_gateway_options: {
          login: 'login',
          password: 'password',
          user: 'user',
          signature: "signature",
          signature_out: "signature"
        }
      }
      @provider_account = FactoryGirl.build_stubbed(:simple_provider, attributes)
      @payment_gateway = @provider_account.payment_gateway

      @account.stubs(provider_account: @provider_account, id: 'account-id')
      @user.stubs(account: @account, email: 'email@example.com')

      @ogone = PaymentGateways::OgoneCrypt.new(@user)
    end

    test '#test? inherits from Active Merchant mode' do
      ActiveMerchant::Billing::Base.stubs(:mode).returns(:test)
      assert @ogone.test?

      ActiveMerchant::Billing::Base.stubs(:mode).returns(:production)
      refute @ogone.test?
    end

    test '#url in :test' do
      ActiveMerchant::Billing::Base.stubs(:mode).returns(:test)
      ogone = PaymentGateways::OgoneCrypt.new(@user)

      assert_equal "https://secure.ogone.com/ncol/test/orderstandard.asp", ogone.url
    end

    test '#url in :production' do
      ActiveMerchant::Billing::Base.stubs(:mode).returns(:production)
      ogone = PaymentGateways::OgoneCrypt.new(@user)

      assert_equal "https://secure.ogone.com/ncol/prod/orderstandard.asp", ogone.url
    end

    test '#update_user' do
      account = FactoryGirl.create :simple_account
      @ogone.stubs(account: account)
      @ogone.update_user('ED' => '0718', 'CARDNO' => 'XXXXXXXXXXXX1111')
      assert_equal '2018-07-01', account.credit_card_expires_on_with_default.to_s
      assert_equal '1111', account.credit_card_partial_number
    end

  end
end

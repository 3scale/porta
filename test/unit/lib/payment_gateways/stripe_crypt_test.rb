# frozen_string_literal: true

require 'test_helper'

module PaymentGateways
  class StripeCryptTest < ActiveSupport::TestCase
    def setup
      @provider_account = FactoryBot.create(:simple_provider, payment_gateway_type: :stripe, payment_gateway_options: {login: 'sk_test_4eC39HqLyjWDarjtT1zdp7dc'})
      @buyer_account = FactoryBot.create(:simple_buyer, provider_account: provider_account)
      @buyer_user = FactoryBot.create(:user, account: buyer_account)
    end

    attr_reader :provider_account, :buyer_account, :buyer_user

    test 'create_stripe_setup_intent' do
      customer = Stripe::Customer.new(id: 'cus_IhGaGqpp6zGwyd')
      Stripe::Customer.stubs(:create).returns(customer)

      expected_stripe_setup_intent = { payment_method_types: ['card'], usage: 'off_session', customer: customer.id }
      expected_setup_intent = Stripe::SetupIntent.new(id: 'seti_1I5s0l2eZvKYlo2CjumP89gc')
      Stripe::SetupIntent.expects(:create).with(expected_stripe_setup_intent, api_key).returns(expected_setup_intent)

      setup_intent = stripe_crypt.create_stripe_setup_intent
      assert_equal expected_setup_intent.id, setup_intent.id
    end

    test 'update!' do
      payment_method_id = 'pm_1I5s3n2eZvKYlo2CiO193T69'

      card_data = {exp_month: 8, exp_year: 1.year.from_now.year, last4: '4242'}
      payment_method_data = {id: payment_method_id, object: 'payment_method', card: card_data, customer: 'cus_IhGaGqpp6zGwyd', type: 'card'}
      payment_method = Stripe::PaymentMethod.new(id: payment_method_id).tap { |pm| pm.update_attributes(payment_method_data) }
      Stripe::PaymentMethod.expects(:retrieve).with(payment_method_id, api_key).returns(payment_method)

      assert stripe_crypt.update!(payment_method_id)

      payment_detail = buyer_account.payment_detail
      assert_equal(Date.new(card_data[:exp_year], card_data[:exp_month]), payment_detail.credit_card_expires_on)
      assert_equal card_data[:last4], payment_detail.credit_card_partial_number
      assert_equal payment_method_data[:customer], payment_detail.credit_card_auth_code
      assert_equal payment_method_id, payment_detail.payment_method_id
    end

    def api_key
      provider_account.payment_gateway_options.fetch(:login)
    end

    def stripe_crypt
      PaymentGateways::StripeCrypt.new(buyer_user)
    end
  end
end

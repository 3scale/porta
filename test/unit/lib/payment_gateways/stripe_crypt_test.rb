# frozen_string_literal: true

require 'test_helper'

module PaymentGateways
  class StripeCryptTest < ActiveSupport::TestCase
    def setup
      @provider_account = FactoryBot.create(:simple_provider, payment_gateway_type: :stripe, payment_gateway_options: {login: 'sk_test_4eC39HqLyjWDarjtT1zdp7dc'})
      @buyer_account = FactoryBot.create(:simple_buyer, provider_account: provider_account)
      @buyer_user = FactoryBot.create(:user, account: buyer_account)
      @stripe_crypt = PaymentGateways::StripeCrypt.new(buyer_user)
    end

    attr_reader :provider_account, :buyer_account, :buyer_user, :stripe_crypt

    test 'create_stripe_setup_intent' do
      customer = mock_customer(id: 'cus_IhGaGqpp6zGwyd')
      Stripe::Customer.stubs(:create).returns(customer)

      expected_stripe_setup_intent = { payment_method_types: ['card'], usage: 'off_session', customer: customer.id }
      expected_setup_intent = Stripe::SetupIntent.new(id: 'seti_1I5s0l2eZvKYlo2CjumP89gc')
      Stripe::SetupIntent.expects(:create).with(expected_stripe_setup_intent, api_key).returns(expected_setup_intent)

      setup_intent = stripe_crypt.create_stripe_setup_intent
      assert_equal expected_setup_intent.id, setup_intent.id
    end

    test 'customer - missing payment detail' do
      Stripe::Customer.expects(:create).with(create_customer_params, api_key).returns(mock_customer)
      refute buyer_account.payment_detail.credit_card_auth_code
      assert_equal 'new-customer-id', stripe_crypt.customer.id
      assert_equal 'new-customer-id', buyer_account.payment_detail.reload.credit_card_auth_code
    end

    test 'customer - existing payment detail' do
      stripe_crypt.payment_detail.delete
      payment_detail = FactoryBot.create(:payment_detail, account: buyer_account)
      stripe_crypt.account.reload
      customer_id = payment_detail.credit_card_auth_code
      Stripe::Customer.expects(:retrieve).with(customer_id, api_key).returns(mock_customer(id: customer_id))
      assert_equal customer_id, stripe_crypt.customer.id
    end

    test 'customer - existing payment detail with a "deleted" customer' do
      stripe_crypt.payment_detail.delete
      payment_detail = FactoryBot.create(:payment_detail, account: buyer_account)
      stripe_crypt.account.reload
      customer_id = payment_detail.credit_card_auth_code
      Stripe::Customer.expects(:retrieve).with(customer_id, api_key).returns(mock_customer(id: customer_id, deleted: true))
      Stripe::Customer.expects(:create).with(create_customer_params, api_key).returns(mock_customer(id: 'new-created-customer-id'))
      assert_equal 'new-created-customer-id', stripe_crypt.customer.id
    end

    test 'create_stripe_setup_intent finds existing customer' do
      stripe_crypt.stubs(:customer).returns(mock_customer(id: 'existing-customer-id'))
      setup_intent_params = { payment_method_types: ['card'], usage: 'off_session', customer: 'existing-customer-id' }
      Stripe::SetupIntent.expects(:create).with(setup_intent_params, api_key).returns(true)
      assert stripe_crypt.create_stripe_setup_intent
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

    def buyer_reference
      "3scale-#{provider_account.id}-#{buyer_account.id}"
    end

    def create_customer_params
      { description: buyer_account.org_name, email: buyer_user.email, metadata: { '3scale_account_reference' => buyer_reference } }
    end

    def mock_customer(**attrs)
      id = attrs.delete(:id) || 'new-customer-id'
      Stripe::Customer.new(id: id).tap { |stripe_customer| stripe_customer.update_attributes(**attrs) }
    end
  end
end

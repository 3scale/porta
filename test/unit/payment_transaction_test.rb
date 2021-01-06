require 'test_helper'

class PaymentTransactionTest < ActiveSupport::TestCase
  should belong_to :account
  should belong_to :invoice
  should validate_presence_of :amount

  test "purchase_with_authorize_net with arrays" do
    payment_transaction = PaymentTransaction.new

    gateway = stubs(:gateway)
    profile_response = stubs(:profile_response)
    profile_response.stubs(:success?).returns(true)
    profile_response.stubs(:params).returns({'profile' => {'payment_profiles' => [{},{"customer_payment_profile_id" => '5678'}]}})
    payment_transaction.stubs(get_profile_response: profile_response)

    cim_gateway = stubs(:cim_gateway)

    expected_hash = {:transaction => {
        :customer_profile_id => '1234',
        :customer_payment_profile_id => '5678',
        :type => :auth_capture,
        :amount => 10.0 }
    }

    payment_transaction.stubs(amount: 10)
    cim_gateway.expects(:create_customer_profile_transaction).with(expected_hash)
    gateway.stubs(cim_gateway: cim_gateway)

    payment_transaction.send(:purchase_with_authorize_net, '1234', gateway)
  end

  test "purchase_with_authorize_net with hashes" do
    payment_transaction = PaymentTransaction.new

    gateway = stubs(:gateway)
    profile_response = stubs(:profile_response)
    profile_response.stubs(:success?).returns(true)
    profile_response.stubs(:params).returns({'profile' => {'payment_profiles' => {"customer_payment_profile_id" => '5678'}}})
    payment_transaction.stubs(get_profile_response: profile_response)

    cim_gateway = stubs(:cim_gateway)

    expected_hash = {:transaction => {
        :customer_profile_id => '1234',
        :customer_payment_profile_id => '5678',
        :type => :auth_capture,
        :amount => 10.0 }
    }

    payment_transaction.stubs(amount: 10)
    cim_gateway.expects(:create_customer_profile_transaction).with(expected_hash)
    gateway.stubs(cim_gateway: cim_gateway)

    payment_transaction.send(:purchase_with_authorize_net, '1234', gateway)
  end

  class PurchaseThroughStripeGatewayTest < ActiveSupport::TestCase
    def setup
      @order_id = 3
      @payment_transaction = PaymentTransaction.new(amount: 100, action: :purchase, currency: 'EUR')
      @payment_gateway_options = {login: 'sk_test_4eC39HqLyjWDarjtT1zdp7dc', publishable_key: 'pk_test_TYooMQauvdEDq54NiTphI7jx'}
      @credit_card_auth_code = 'cus_IhGaGqpp6zGwyd'
    end

    attr_reader :order_id, :payment_transaction, :payment_gateway_options, :credit_card_auth_code

    test 'purchase through Stripe with SCA (without extra authorization step required by the bank)' do
      payment_method_id = 'pm_1I5s3n2eZvKYlo2CiO193T69'

      stripe_payment_intents_gateway = ActiveMerchant::Billing::StripePaymentIntentsGateway.new(payment_gateway_options)

      expected_options = {off_session: true, execute_threed: true, order_id: order_id, currency: payment_transaction.currency, customer: credit_card_auth_code}
      response_params = {'id' => 'pi_1I1EAnIxGJbGz9puiiI6e10D', 'paid' => true, 'payment_method' => payment_method_id}
      active_merchant_response = ActiveMerchant::Billing::Response.new(true, 'Transaction approved', response_params, test: false, authorization: response_params['id'], error_code: nil)
      stripe_payment_intents_gateway.expects(:purchase).with(payment_transaction.amount.cents, payment_method_id, expected_options).returns(active_merchant_response)

      assert payment_transaction.process!(credit_card_auth_code, stripe_payment_intents_gateway, {order_id: order_id, payment_method_id: payment_method_id})

      assert_payment_transaction_attributes(payment_transaction, active_merchant_response)
    end

    test 'purchase through Stripe without SCA' do
      stripe_gateway = ActiveMerchant::Billing::StripeGateway.new(payment_gateway_options)

      expected_options = {order_id: order_id, currency: payment_transaction.currency, customer: credit_card_auth_code}
      response_params = {'id' => 'ch_1HxxDgIxGJbGz9puarvnHz6X', 'paid' => true, 'payment_method' => 'card_1HxtiHIxGJbGz9pusM7rTEYS'}
      active_merchant_response = ActiveMerchant::Billing::Response.new(true, 'Transaction approved', response_params, test: false, authorization: response_params['id'], error_code: nil)
      stripe_gateway.expects(:purchase).with(payment_transaction.amount.cents, nil, expected_options).returns(active_merchant_response)

      assert payment_transaction.process!(credit_card_auth_code, stripe_gateway, {order_id: order_id})

      assert_payment_transaction_attributes(payment_transaction, active_merchant_response)
    end

    private

    def assert_payment_transaction_attributes(payment_transaction, active_merchant_response)
      assert_equal active_merchant_response.success?, payment_transaction.success
      assert_equal active_merchant_response.authorization, payment_transaction.reference
      assert_equal active_merchant_response.message, payment_transaction.message
      assert_equal active_merchant_response.params, payment_transaction.params
      assert_equal active_merchant_response.test, payment_transaction.test
    end
  end

  context "PaymentTransaction" do
    setup do
      @transaction = PaymentTransaction.new(:amount => 1000.to_has_money('JPY'))
    end

    should 'get and set amount as money' do
      @transaction.save!
      @transaction.reload
      assert_same 1000.to_has_money('JPY'), @transaction.amount
    end

    context "with card stored in BogusGateway" do
      setup do
        @gateway =  ActiveMerchant::Billing::BogusGateway.new
      end

      should 'process without problems' do
        @transaction.amount = 100.to_has_money('EUR')

        @transaction.process!('1', @gateway, {})

        assert @transaction.success?
        assert_equal 100.to_has_money('EUR'), @transaction.amount
      end
    end
  end


  context "with many transactions" do
    setup do
      3.times { FactoryBot.create(:payment_transaction, :success => true) }
      2.times { FactoryBot.create(:payment_transaction, :success => false) }
    end

    should "have succeeded and failed scoped" do
      assert_equal 3, PaymentTransaction.succeeded.count
      assert_equal 2, PaymentTransaction.failed.count
    end
  end

  context '#to_xml' do
    should "convert params attr correctly" do
      braintree_hash = { "braintree_transaction" =>
                         {"order_id"=>"123456", "status"=>"submitted_for_settlement",
                          "credit_card_details"=>{"masked_number"=>"123456******6789", "bin"=>"123456", "last_4"=>"6789", "card_type"=>"Visa"},
                          "customer_details"=>{"id"=>"98765432", "email"=>nil},
                          "billing_details"=>{"street_address"=>"yanabe Street", "extended_address"=>nil, "company"=>"barmajeyat.com",
                                              "locality"=>"Amman", "region"=>"Amman", "postal_code"=>"11190", "country_name"=>"Jordan"},
                          "shipping_details"=>{"street_address"=>nil, "extended_address"=>nil, "company"=>nil, "locality"=>nil,
                                               "region"=>nil, "postal_code"=>nil, "country_name"=>nil},
                          "vault_customer"=>{"credit_cards"=>[{"bin"=>"123456"}]},
                          "merchant_account_id"=>"bestmerchant"}}

      pt = FactoryBot.create(:payment_transaction, :params => braintree_hash)

      xml = Nokogiri::XML::Document.parse(pt.to_xml)

      assert xml.xpath('.//gateway_response/braintree_transaction').presence
      assert xml.xpath('.//gateway_response/braintree_transaction/order_id').presence
      assert xml.xpath('.//gateway_response/braintree_transaction/credit_card_details').presence

      assert xml.xpath('.//gateway_response/braintree_transaction/customer_details').presence
      assert xml.xpath('.//gateway_response/braintree_transaction/billing_details').presence
      assert xml.xpath('.//gateway_response/braintree_transaction/shipping_details').presence
      assert xml.xpath('.//gateway_response/braintree_transaction/vault_customer/credit_cards').presence
      assert xml.xpath('.//gateway_response/braintree_transaction/merchant_account_id').presence
    end
  end # to_xml
end

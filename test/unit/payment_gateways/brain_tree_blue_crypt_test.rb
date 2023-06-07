require 'test_helper'

module PaymentGateways
  class BrainTreeBlueCryptTest < ActiveSupport::TestCase
    include ActiveMerchantTestHelpers::BraintreeBlue

    def setup
      @user = mock
      @account = mock
      attributes = {
        payment_gateway_type: :braintree_blue,
        payment_gateway_options: {
          public_key: '12345',
          merchant_id: 'aMerchant',
          private_key: 'world'
        }
      }
      @provider_account = FactoryBot.build_stubbed(:simple_provider, attributes)
      @payment_gateway = @provider_account.payment_gateway

      @account.stubs(provider_account: @provider_account, id: 12345678, credit_card_auth_code_was: nil)
      @user.stubs(account: @account, email: 'email@example.com', id: 12345)
      @braintree = PaymentGateways::BrainTreeBlueCrypt.new(@user)
    end

    def test_errors
      result = OpenStruct.new(success?: false, errors: [], gateway: Rails.logger)

      assert @braintree.errors(result)
    end

    test '#test? uses Active Merchant mode :test value' do
      ActiveMerchant::Billing::Base.stubs(:mode).returns(:test)
      assert @braintree.test?
      assert_equal :sandbox, @braintree.gateway_client.config.instance_variable_get('@environment')
    end

    test '#test? uses Active Merchant mode ::production value' do
      ActiveMerchant::Billing::Base.stubs(:mode).returns(:production)
      @braintree = PaymentGateways::BrainTreeBlueCrypt.new(@user)
      refute @braintree.test?
      assert_equal :production, @braintree.gateway_client.config.instance_variable_get('@environment')
    end

    test '#confirm' do
      @braintree.expects(:current_token).returns('token')
      @braintree.customer_gateway.expects(:update).with(@braintree.buyer_reference_for_update, {payment_method_nonce: 'nonce', credit_card: { options: {make_default: true, update_existing_token: 'token'}}})
      @braintree.confirm({}, 'nonce')
    end

    test '#confirm with error caught' do
      @braintree.expects(:current_token).returns('token')
      exception = Braintree::BraintreeError.new('a braintree exception')
      @braintree.customer_gateway.expects(:update).raises(exception)
      @braintree.expects(:notify_exception).with(exception, {buyer_reference: @braintree.buyer_reference_for_update} )
      assert_nothing_raised do
        @braintree.confirm({}, 'nonce')
      end
    end

    test '#buyer_reference' do
      @account.stubs(credit_card_auth_code_was: nil)
      assert_equal "3scale-#{@provider_account.id}-#{@account.id}-1", @braintree.buyer_reference_for_update

      # It should not update the buyer reference if one exists in DB
      @account.stubs(credit_card_auth_code_was: 'hello-world')
      assert_equal 'hello-world', @braintree.buyer_reference_for_update

      @account.stubs(credit_card_auth_code_was: "3scale-#{@provider_account.id}-#{@account.id}-13")
      assert_equal "3scale-#{@provider_account.id}-#{@account.id}-13", @braintree.buyer_reference_for_update
    end

    test '#create_customer_data when there is already one stored in Braintree' do
      found_response = mock
      credit_card = mock
      credit_card.stubs(token: 'a_token')
      found_response.stubs(id: 'customer_id', credit_cards: [credit_card])

      data = { billing_address: { firstname: 'John', lastname: 'Doe' } }

      @braintree.expects(:find_customer).returns(found_response).at_least_once
      @braintree.customer_gateway.expects(:update).with('customer_id', data.merge({credit_card: { options: { update_existing_token: 'a_token' } } }))
      @braintree.create_customer_data(data)
    end

    test '#create_customer_data when there is none stored in Braintree' do
      data = { billing_address: { firstname: 'John', lastname: 'Doe' } }
      @braintree.stubs(:find_customer).returns(nil)
      @braintree.customer_gateway.expects(:create).with(data.merge(id: @braintree.buyer_reference_for_update))

      @braintree.create_customer_data(data)
    end

    test '#update_user with correct customer.id' do
      result = successful_result
      account = Account.new
      account.expects(:save!).returns(true)
      @braintree.stubs(:account).returns(account)
      @braintree.expects(:buyer_reference).returns(result.customer.id)
      assert @braintree.update_user(result)

      account_keys = %w(
        billing_address_first_name
        billing_address_last_name
        billing_address_phone
        billing_address_name
        billing_address_address1
        billing_address_city
        billing_address_country
        billing_address_state
        billing_address_zip
      )
      account_changes = account.changes.keys

      account_keys.each do |k|
        assert_includes account_changes, k
      end

      payment_detail_keys = %w(
        buyer_reference
        credit_card_partial_number
        credit_card_expires_on
      )
      payment_detail_changes = account.payment_detail.changes.keys

      payment_detail_keys.each do |k|
        assert_includes payment_detail_changes, k
      end
    end

    test '#update_user wit mismatch customer.id' do
      result = successful_result
      account = Account.new
      account.expects(:save!).never
      @braintree.stubs(:account).returns(account)
      System::ErrorReporting.expects(:report_error).with(instance_of(PaymentGateways::CustomerIdMismatchError), instance_of(Hash))
      @braintree.expects(:buyer_reference).at_least_once.returns('garbage')
      refute @braintree.update_user(result)
    end

    test '#buyer_reference takes into account the last saved customer.id' do
      account = FactoryBot.create(:simple_provider)
      account.update(credit_card_auth_code: "#{@braintree.buyer_reference}-3")
      @braintree.stubs(:account).returns(account)
      account.credit_card_auth_code = nil
      assert_equal "#{@braintree.buyer_reference}-3", @braintree.buyer_reference_for_update
    end
  end
end

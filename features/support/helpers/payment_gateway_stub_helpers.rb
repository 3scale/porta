# frozen_string_literal: true

module PaymentGatewayStubHelpers
  def stub_braintree_authorization(times: 1)
    braintree_crypt.stubs(:create_customer_data).returns(braintree_customer).times(times) # This would call find then either update or create customer, then returns customer object but it's ignored by controller. Mocking it skips sending post braintree API customers
    braintree_crypt.stubs(:authorization).returns('mocked_authorization').times(times) # This skips sending post braintree API client_token
  end

  def stub_stripe_intent_setup(times: 1)
    instance = mock
    instance.stubs(:client_secret).returns(provider_stripe_client_secret_example)
    stripe_crypt.expects(:create_stripe_setup_intent).returns(instance).times(times)
  end

  def stub_successful_braintree_update(billing_address: billing_address_example_data, credit_card: credit_card_example_data)
    result = Braintree::SuccessfulResult.new(customer: braintree_customer(address: billing_address, credit_card: credit_card))

    braintree_crypt.stubs(:confirm).returns(result).once
    braintree_crypt.stubs(:customer_id_mismatch?).with(result).returns(false).once # Though ideal, we cannot stub update_user here since account would not updated with form values
  end

  def stub_wrong_braintree_update
    braintree_crypt.stubs(:confirm).returns(Braintree::ErrorResult.new(:gateway, failed_braintree_hash)).once
  end

  def stub_braintree_correct_configuration
    Braintree::Configuration.any_instance.stubs(:assert_has_access_token_or_keys).returns(true)
  end

  def stub_braintree_wrong_configuration
    PaymentGateways::BrainTreeBlueCrypt.expects(:new).raises(Braintree::ConfigurationError).once
  end

  def expect_braintree_customer_id_mismatch
    braintree_crypt.unstub(:customer_id_mismatch?)
    braintree_crypt.expects(:customer_id_mismatch?).returns(true).once
  end

  def customer_hash(address = billing_address_example_data, credit_card = credit_card_example_data)
    {
      id: 123,
      first_name: address[:first_name],
      last_name: address[:last_name],
      credit_cards: [{
        expiration_year: credit_card[:expiration_year],
        expiration_month: credit_card[:expiration_month],
        last_4: credit_card[:partial_number] # rubocop:disable Naming/VariableNumber Defined by Braintree API
      }],
      addresses: [{
        company: address[:company],
        street_address: address[:street_address],
        locality: address[:locality],
        country_name: address[:country_name],
        region: address[:region],
        postal_code: address[:postal_code]
      }],
      phone: address[:phone]
    }
  end

  def buyer_credit_card_expiration_date(credit_card = credit_card_example_data)
    Date.new(credit_card[:expiration_year].to_i, credit_card[:expiration_month].to_i)
  end

  def braintree_customer(address: billing_address_example_data, credit_card: credit_card_example_data)
    Braintree::Customer._new(:gateway, customer_hash(address, credit_card))
  end

  def failed_braintree_hash
    {
      errors: {
        address: {
          errors: [{
            message: 'Credit card number is invalid'
          }]
        }
      }
    }
  end

  def provider_stripe_id_example
    'seti_1LwLzLH2pBu3kj9oxjYUwxeA'
  end

  def provider_stripe_secret_example
    'MfhOTm6ihcdQ5sWr4e8BniCDuNHyCi6'
  end

  def provider_stripe_client_secret_example
    # (!) This is NOT a real secret. Stripe.js verifies the format is ${id}_secret_${secret} before sending a request.
    "#{provider_stripe_id_example}_secret_#{provider_stripe_secret_example}"
  end

  private

  def braintree_crypt
    PaymentGateways::BrainTreeBlueCrypt.any_instance
  end

  def stripe_crypt
    PaymentGateways::StripeCrypt.any_instance
  end

  def confirm_customer_info(address)
    {
      'first_name' => address[:first_name],
      'last_name' => address[:last_name],
      'phone' => address[:phone],
      'credit_card' => {
        'billing_address' => {
          'company' => address[:company],
          'street_address' => address[:street_address],
          'postal_code' => address[:postal_code],
          'locality' => address[:locality],
          'region' => address[:region],
          'country_name' => address[:country_code] # Are we sending the correct property to Braintree? Maybe we send the code but we want to send the full name?
        }
      }
    }
  end
end

World(PaymentGatewayStubHelpers)

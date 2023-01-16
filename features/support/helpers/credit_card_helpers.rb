# frozen_string_literal: true

module CreditCardHelpers
  def billing_address_example_data
    {
      first_name: 'Bender',
      last_name: 'Rodriguez',
      company: 'Planet Express',
      street_address: 'Undisclosed Location 123',
      extra_address: '',
      locality: 'New New York',
      country_code: 'US',
      country_name: 'United States',
      region: 'New New York',
      postal_code: '123456',
      phone: '+34666777888'
    }
  end

  alias address billing_address_example_data

  def credit_card_example_data
    {
      auth_code: 'abc123',
      expiration_year: '2025',
      expiration_month: '12',
      number: '4111111111111111',
      ccv: '123',
      partial_number: '1111'
    }
  end

  alias credit_card credit_card_example_data
end

World(CreditCardHelpers)

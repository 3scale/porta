module CreditCardHelpers
  def customer_hash
    {
      id: 123, first_name: 'asd', last_name: 'zxc',
      credit_cards: [{ expiration_year: '2018', expiration_month: '12', last_4: '1111' }],
      addresses: [{ company: 'foo', street_address: 'street',
                    locality: 'bcn', country_name: 'cat',
                    region: 'foo', postal_code: '708080' }],
      phone: 979797979
    }
  end

  def successful_braintree_result
    Braintree::SuccessfulResult.new(customer: braintree_customer)
  end

  def braintree_customer
    Braintree::Customer._new(:gateway, customer_hash)
  end

  def failed_braintree_result
    hash = { params: { customer: { last_name: 'fdsa', credit_card: {
      billing_address: { locality: 'fda', company: 'fdsa', postal_code: '08080', country_name: 'Albania', region: 'fdas', street_address: 'fdsa' },
      expiration_date: '12/13' }, phone: '123123', first_name: 'Raimon' },
                       authenticity_token: 'example_token',
                       commit: 'Save Details'
      },
             errors: { address: { errors: [{ message: 'Credit card number is invalid' }] }
      }
    }
    Braintree::ErrorResult.new(:gateway, hash)
  end
end
World(CreditCardHelpers)

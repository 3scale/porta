import client from 'braintree-web/client'
import hostedFields from 'braintree-web/hosted-fields'
import threeDSecure from 'braintree-web/three-d-secure'

const form = document.querySelector('#customer_form')
const clientToken = form.dataset.clientToken
const braintreeNonce = document.querySelector('#braintree_nonce')

const getBillingAdressInfo = () => (
  {
    givenName: document.querySelector('#customer_credit_card_billing_address_company').value,
    streetAddress: document.querySelector('#customer_credit_card_billing_address_street_address').value,
    postalCode: document.querySelector('#customer_credit_card_billing_address_postal_code').value,
    locality: document.querySelector('#customer_credit_card_billing_address_locality').value,
    region: document.querySelector('#customer_credit_card_billing_address_region').value || null,
    countryCodeAlpha2: document.querySelector('#customer_credit_card_billing_address_country_name').value
  }
)

const hostedFieldOptions = {
  styles: {
    'input': {
      'font-size': '14px'
    },
    'input.invalid': {
      'color': 'red'
    },
    'input.valid': {
      'color': 'green'
    }
  },
  fields: {
    number: {
      selector: '#customer_credit_card_number',
      placeholder: '4111 1111 1111 1111'
    },
    cvv: {
      selector: '#customer_credit_card_cvv',
      placeholder: '123'
    },
    expirationDate: {
      selector: '#customer_credit_card_expiration_date',
      placeholder: 'MM/YY'
    }
  }
}

const veryfyCard = (threeDSecureInstance, payload) => {
  const threeDSecureParameters = {
    amount: '00.00',
    billingAddress: getBillingAdressInfo(),
    onLookupComplete: function (data, next) {
      next()
    }
  }
  const options = {
    nonce: payload.nonce,
    bin: payload.details.bin,
    challengeRequested: true,
    ...threeDSecureParameters
  }
  threeDSecureInstance.verifyCard(options, function (err, response) {
    if (err) {
      console.error(err)
      return
    }
    braintreeNonce.value = response.nonce
    form.submit()
  })
}

const create3DSecure = (clientInstance, payload) => {
  threeDSecure.create({
    version: 2,
    client: clientInstance
  }, function (threeDSecureErr, threeDSecureInstance) {
    if (threeDSecureErr) {
      throw new Error('Error creating 3DSecure' + threeDSecureErr)
    }
    veryfyCard(threeDSecureInstance, payload)
  })
}

client.create({
  authorization: clientToken
}, function (clientErr, clientInstance) {
  if (clientErr) {
    console.error(clientErr)
    return
  }

  hostedFields.create({
    client: clientInstance,
    ...hostedFieldOptions
  }, function (hostedFieldsErr, hostedFieldsInstance) {
    if (hostedFieldsErr) {
      console.error(hostedFieldsErr)
      return
    }

    form.addEventListener('submit', function (event) {
      event.preventDefault()
      hostedFieldsInstance.tokenize(function (tokenizeErr, payload) {
        if (tokenizeErr) {
          console.error(tokenizeErr)
          return
        }
        create3DSecure(clientInstance, payload)
      })
    })
  })
})

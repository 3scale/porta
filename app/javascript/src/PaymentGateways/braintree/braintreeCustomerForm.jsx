/* eslint-disable no-console */
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

const createBraintreeClient = (client, clientToken) => {
  return client.create({ authorization: clientToken })
    .then((clientInstance) => clientInstance)
    .catch(error => console.error(error))
}

const createHostedFieldsInstance = (hostedFields, clientInstance, hostedFieldOptions) => {
  return hostedFields.create({
    client: clientInstance,
    ...hostedFieldOptions
  })
    .then((hostedFieldsInstance) => hostedFieldsInstance)
    .catch(error => console.error(error))
}

const create3DSecureInstance = async (threeDSecure, clientInstance, payload) => {
  return await threeDSecure.create({
    version: 2,
    client: clientInstance
  })
    .then(threeDSecureInstance => threeDSecureInstance)
    .catch(error => console.error(error))
}

const veryfyCard = async (threeDSecureInstance, payload) => {
  const threeDSecureParameters = {
    amount: '00.00',
    billingAddress: {}, // Todo: get values from form
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
  const response = await threeDSecureInstance.verifyCard(options)
    .then(response => response)
    .catch(error => console.error(error))

  return response
}

export {
  hostedFieldOptions,
  createBraintreeClient,
  createHostedFieldsInstance,
  create3DSecureInstance,
  veryfyCard
}

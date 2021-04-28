const validationConstraints = {
  'customer[first_name]': {
    presence: {
      message: '^isMandatory'
    }
  },
  'customer[last_name]': {
    presence: {
      message: '^isMandatory'
    }
  },
  'customer[credit_card][billing_address][company]': {
    presence: {
      message: '^isMandatory'
    }
  },
  'customer[credit_card][billing_address][street_address]': {
    presence: {
      message: '^isMandatory'
    }
  },
  'customer[credit_card][billing_address][postal_code]': {
    presence: {
      message: '^isMandatory'
    }
  },
  'customer[credit_card][billing_address][locality]': {
    presence: {
      message: '^isMandatory'
    }
  },
  'customer[credit_card][billing_address][country_name]': {
    presence: {
      message: '^isMandatory'
    }
  }
}

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

const createHostedFieldsInstance = (hostedFields, clientInstance, hostedFieldOptions, setIsCardValid) => {
  return hostedFields.create({
    client: clientInstance,
    ...hostedFieldOptions
  })
    .then((hostedFieldsInstance) => {
      hostedFieldsInstance.on('validityChange', () => {
        const state = hostedFieldsInstance.getState()
        const cardValid = Object.keys(state.fields).every((key) => state.fields[key].isValid)
        setIsCardValid(cardValid)
      })
      return hostedFieldsInstance
    })
    .catch(error => console.error(error))
}
const create3DSecureInstance = async (threeDSecure, clientInstance) => {
  return await threeDSecure.create({
    version: 2,
    client: clientInstance
  })
    .then(threeDSecureInstance => threeDSecureInstance)
    .catch(error => console.error(error))
}

const veryfyCard = async (threeDSecureInstance, payload, billingAddress) => {
  const threeDSecureParameters = {
    amount: '00.00',
    billingAddress,
    onLookupComplete: (data, next) => next()
  }
  const options = {
    nonce: payload.nonce,
    bin: payload.details.bin,
    challengeRequested: true,
    ...threeDSecureParameters
  }
  return await threeDSecureInstance.verifyCard(options)
    .then(response => response)
    .catch(error => error)
}

export {
  validationConstraints,
  hostedFieldOptions,
  createBraintreeClient,
  createHostedFieldsInstance,
  create3DSecureInstance,
  veryfyCard
}

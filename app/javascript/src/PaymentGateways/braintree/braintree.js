// @flow

/* eslint-disable flowtype/no-weak-types */

import type { BillingAddressData, HostedFieldsOptions } from 'PaymentGateways'

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
  'customer[phone]': {
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
      placeholder: 'Enter a valid credit card number'
    },
    cvv: {
      selector: '#customer_credit_card_cvv',
      placeholder: 'Enter a valid CVV number'
    },
    expirationDate: {
      selector: '#customer_credit_card_expiration_date',
      placeholder: 'MM/YY'
    }
  }
}

const createBraintreeClient = (client: any, clientToken: string): any => {
  return client.create({ authorization: clientToken })
    .then((clientInstance) => clientInstance)
    .catch(error => console.error(error))
}

const createHostedFieldsInstance = (
  hostedFields: any,
  clientInstance: any,
  hostedFieldOptions: HostedFieldsOptions,
  setIsCardValid: (cardValid: boolean) => void,
  setCardError: (err: string | null) => void
): any => {
  return hostedFields.create({
    ...hostedFieldOptions,
    client: clientInstance
  })
    .then((hostedFieldsInstance) => {
      hostedFieldsInstance.on('validityChange', () => {
        const state = hostedFieldsInstance.getState()
        const cardValid = Object.keys(state.fields).every((key) => state.fields[key].isValid)
        setIsCardValid(cardValid)
      })
      hostedFieldsInstance.on('focus', () => setCardError(null))
      return hostedFieldsInstance
    })
    .catch(error => console.error(error))
}
const create3DSecureInstance = async (threeDSecure: any, clientInstance: any): Promise<any> => {
  return threeDSecure.create({
    version: 2,
    client: clientInstance
  })
    .then(threeDSecureInstance => threeDSecureInstance)
    .catch(error => console.error(error))
}

const veryfyCard = async (threeDSecureInstance: any, payload: any, billingAddress: BillingAddressData): Promise<any> => {
  const threeDSecureParameters = {
    amount: '0.00',
    billingAddress,
    onLookupComplete: (data, next) => next()
  }
  const options = {
    nonce: payload.nonce,
    bin: payload.details.bin,
    challengeRequested: true,
    ...threeDSecureParameters
  }
  return threeDSecureInstance.verifyCard(options)
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

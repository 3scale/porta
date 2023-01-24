import type { Client, HostedFields, ThreeDSecure } from 'braintree-web'
import type { HostedFieldsFieldDataFields, HostedFieldsTokenizePayload } from 'braintree-web/modules/hosted-fields'
import type { ThreeDSecureVerificationData, ThreeDSecureVerifyOptions } from 'braintree-web/modules/three-d-secure'
import type { HostedFieldsOptions, BillingAddressData } from 'PaymentGateways/braintree/types'

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

const createBraintreeClient = (client: Client, clientToken: string): Promise<unknown> => {
  return client.create({ authorization: clientToken })
    .then((clientInstance) => clientInstance)
    .catch(error => { console.error(error) })
}

const createHostedFieldsInstance = (
  hostedFields: HostedFields,
  clientInstance: Client,
  // eslint-disable-next-line @typescript-eslint/no-shadow -- FIXME: We really need to fix this mess.
  hostedFieldOptions: HostedFieldsOptions,
  setIsCardValid: (cardValid: boolean) => void,
  setCardError: (err: string | null) => void
): Promise<unknown> => {
  return hostedFields.create({
    ...hostedFieldOptions,
    client: clientInstance
  })
    .then((hostedFieldsInstance) => {
      hostedFieldsInstance.on('validityChange', () => {
        const state = hostedFieldsInstance.getState()
        const cardValid = Object.keys(state.fields).every((key) => state.fields[key as keyof HostedFieldsFieldDataFields].isValid)
        setIsCardValid(cardValid)
      })
      hostedFieldsInstance.on('focus', () => { setCardError(null) })
      return hostedFieldsInstance
    })
    .catch(error => { console.error(error) })
}
const create3DSecureInstance = (threeDSecure: ThreeDSecure, clientInstance: Client): Promise<unknown> => {
  return threeDSecure.create({
    version: 2,
    client: clientInstance
  })
    .then(threeDSecureInstance => threeDSecureInstance)
    .catch(error => { console.error(error) })
}

const veryfyCard = (
  threeDSecureInstance: ThreeDSecure,
  payload: HostedFieldsTokenizePayload,
  billingAddress: BillingAddressData
): Promise<unknown> => {
  const options: ThreeDSecureVerifyOptions = {
    nonce: payload.nonce,
    bin: payload.details.bin,
    challengeRequested: true,
    amount: 0.0,
    // eslint-disable-next-line @typescript-eslint/no-unsafe-assignment
    billingAddress,
    onLookupComplete: (_data: ThreeDSecureVerificationData, next: () => void) => { next() } // From https://github.com/DefinitelyTyped/DefinitelyTyped/pull/61818/commits/8411fba432567e70b1cd6bf7c79a88e7dd9a6aee
  } as ThreeDSecureVerifyOptions /* TODO: 2 things wrong with this:
                                    - Types must be outdated, onLookupComplete is missing from ThreeDSecureVerifyOptions.
                                    - billingAddress is completely wrong?? BillingAddressData (custom) vs. ThreeDSecureBillingAddress (what takes verifyCard) */
  return threeDSecureInstance.verifyCard(options)
    .then(response => response)
    // eslint-disable-next-line @typescript-eslint/no-unsafe-return -- FIXME: this is a sensitive piece of code so better refactor this return later
    .catch(error => error)
}

export {
  hostedFieldOptions,
  createBraintreeClient,
  createHostedFieldsInstance,
  create3DSecureInstance,
  veryfyCard
}

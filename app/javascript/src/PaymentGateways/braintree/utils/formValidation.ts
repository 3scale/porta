import validate from 'validate.js'

import type { BillingAddressData } from 'PaymentGateways/braintree/types'

const VALIDATION_CONSTRAINTS = {
  // firstName: {
  //   presence: true,
  //   length: { minimum: 1 }
  // },
  // lastName: {
  //   presence: true,
  //   length: { minimum: 1 }
  // },
  // phone: {
  //   presence: true,
  //   length: { minimum: 1 }
  // },
  company: {
    presence: true,
    length: { minimum: 1 }
  },
  address: {
    presence: true,
    length: { minimum: 1 }
  },
  zip: {
    presence: true,
    length: { minimum: 1 }
  },
  city: {
    presence: true,
    length: { minimum: 1 }
  },
  country: {
    presence: true,
    length: { minimum: 1 }
  }
} as const

const validateForm = (fields: BillingAddressData): Record<keyof typeof VALIDATION_CONSTRAINTS, string[]> | undefined => {
  const formErrors = validate(fields, VALIDATION_CONSTRAINTS) as (Record<keyof typeof VALIDATION_CONSTRAINTS, string[]> | undefined)
  return formErrors
}

export { validateForm }

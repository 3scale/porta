import validate from 'validate.js'

import type { BillingAddress } from 'PaymentGateways/braintree/types'

// TODO: use correct validation constraints
const VALIDATION_CONSTRAINTS: Record<Exclude<keyof BillingAddress, 'countryCodeAlpha2'>, unknown> = {
  firstName: {
    presence: { allowEmpty: false }
  },
  lastName: {
    presence: { allowEmpty: false }
  },
  phone: {
    presence: { allowEmpty: false }
  },
  company: {
    presence: { allowEmpty: false }
  },
  address: {
    presence: { allowEmpty: false }
  },
  zip: {
    presence: { allowEmpty: false }
  },
  city: {
    presence: { allowEmpty: false }
  },
  state: {
    presence: false
  },
  country: {
    presence: { allowEmpty: false }
  }
} as const

const validateForm = (fields: Partial<BillingAddress>): Partial<Record<keyof typeof VALIDATION_CONSTRAINTS, string[]>> | undefined => {
  const formErrors = validate(fields, VALIDATION_CONSTRAINTS) as (Record<keyof typeof VALIDATION_CONSTRAINTS, string[]> | undefined)
  return formErrors
}

export { validateForm }

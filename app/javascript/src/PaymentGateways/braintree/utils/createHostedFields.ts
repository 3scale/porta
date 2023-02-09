import { client, hostedFields } from 'braintree-web'

import type { HostedFields } from 'braintree-web'
import type { HostedFieldFieldOptions } from 'braintree-web/modules/hosted-fields'

const styles = {
  'input': {
    'font-size': '14px'
  },
  'input.invalid': {
    'color': 'red'
  },
  'input.valid': {
    'color': 'green'
  }
} as const

const fields: HostedFieldFieldOptions = {
  number: {
    container: '#customer_credit_card_number',
    placeholder: 'Enter a valid credit card number'
  },
  cvv: {
    container: '#customer_credit_card_cvv',
    placeholder: 'Enter a valid CVV number'
  },
  expirationDate: {
    container: '#customer_credit_card_expiration_date',
    placeholder: 'MM/YY'
  }
} as const

const createHostedFields = async (authorization: string): Promise<HostedFields> => (
  client.create({ authorization }).then(() => ( // HACK: Instantiate client first to catch any authorization error. See https://github.com/braintree/braintree-web/issues/669.
    hostedFields.create({ authorization, fields, styles }))
  )
)

export { createHostedFields }

import * as flash from 'utilities/flash'
import { createHostedFields } from 'PaymentGateways/braintree/utils/createHostedFields'

import type { BraintreeError } from 'braintree-web'

document.addEventListener('DOMContentLoaded', () => {
  const form = document.querySelector<HTMLFormElement>('form#new_customer')
  const submit = document.querySelector<HTMLButtonElement>('button[type="submit"]')
  const hostedFieldset = document.querySelector<HTMLElement>('fieldset#hosted-fields')
  const fakeFieldset = document.querySelector<HTMLElement>('fieldset#fake-fields')
  const nonce = document.querySelector<HTMLInputElement>('input#braintree_nonce')

  if (!(submit && form && hostedFieldset && fakeFieldset && nonce)) {
    throw new Error('Required elements not found')
  }

  const clientToken = document.getElementById('braintree_data')?.dataset.clientToken

  if (!clientToken) {
    throw new Error('Braintree token not found')
  }

  void createHostedFields(clientToken)
    .then(hostedFieldsInstance => {
      fakeFieldset.remove()
      hostedFieldset.style.display = 'revert'
      submit.removeAttribute('disabled')

      form.addEventListener('submit', (event: Event) => {
        event.preventDefault()
        event.stopPropagation()
        submit.setAttribute('disabled', 'disabled')

        hostedFieldsInstance.tokenize()
          .then(payload => {
            nonce.setAttribute('value', payload.nonce)
            form.submit()
          })
          .catch((error: BraintreeError) => {
            submit.removeAttribute('disabled')
            flash.error('Credit card could not be updated.')
            console.error(error)
          })
      })
    })
    .catch((error: BraintreeError) => {
      console.error(error)
    })
})

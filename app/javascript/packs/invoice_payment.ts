/* eslint-disable @typescript-eslint/no-non-null-assertion -- FIXME: good luck with that */

import { loadStripe } from '@stripe/stripe-js'
import 'PaymentGateways/stripe/components/StripeFormWrapper.scss'

import type { PaymentIntent, Stripe, StripeCardElement } from '@stripe/stripe-js'

const style = {
  base: {
    color: '#32325d',
    fontFamily: 'Arial, sans-serif',
    fontSmoothing: 'antialiased',
    fontSize: '16px',
    '::placeholder': {
      color: '#32325d'
    }
  },
  invalid: {
    fontFamily: 'Arial, sans-serif',
    color: '#fa755a',
    iconColor: '#fa755a'
  }
}

// eslint-disable-next-line @typescript-eslint/no-misused-promises
document.addEventListener('DOMContentLoaded', async () => {
  const dataset = document.querySelector<HTMLElement>('.stripe-form')!.dataset
  const { stripePublishableKey = '', clientSecret = '' } = dataset
  const form = document.querySelector('#payment-form')!
  const callbackForm = document.querySelector<HTMLFormElement>('#payment-callback-form')!
  const payButton = document.querySelector<HTMLButtonElement>('#submit-payment')!
  const cardError = document.querySelector('#card-error')!
  const errorMsg = document.querySelector('#card-error')!
  const spinner = document.querySelector('#spinner')!
  const buttonText = document.querySelector('#button-text')!

  const stripe = await loadStripe(stripePublishableKey)!
  const elements = stripe!.elements()
  const card = elements.create('card', { style })

  // eslint-disable-next-line @typescript-eslint/no-shadow
  const payWithCard = (stripe: Stripe, card: StripeCardElement, clientSecret: string) => {
    setLoading(true)
    void stripe.confirmCardPayment(clientSecret, {
      // eslint-disable-next-line @typescript-eslint/naming-convention -- Stripe API
      payment_method: {
        card: card
      }
    }).then(function (result) {
      if (result.error) {
        showError(result.error.message)
      } else {
        orderComplete(result.paymentIntent)
      }
    })
  }

  const orderComplete = (paymentIntent: PaymentIntent) => {
    Object.keys(paymentIntent).forEach(key => {
      const hiddenField = document.createElement('input')
      hiddenField.type = 'hidden'
      hiddenField.name = `payment_intent[${key}]`
      // @ts-expect-error FIXME: no idea where this comes from
      hiddenField.value = paymentIntent[key] as string
      callbackForm.appendChild(hiddenField)
    })
    callbackForm.submit()
  }

  const showError = (errorMsgText = '') => {
    setLoading(false)
    errorMsg.textContent = errorMsgText
    setTimeout(() => {
      errorMsg.textContent = ''
    }, 4000)
  }

  const setLoading = (isLoading: boolean) => {
    payButton.disabled = isLoading
    spinner.classList.toggle('hidden', !isLoading)
    buttonText.classList.toggle('hidden', isLoading)
  }

  payButton.disabled = true
  card.mount('#card-element')
  card.on('change', event => {
    payButton.disabled = !event.complete
    cardError.textContent = event.error?.message ?? ''
  })
  form.addEventListener('submit', function (event) {
    event.preventDefault()
    // @ts-expect-error FIXME: we can't simply assume stripe instance will be there
    payWithCard(stripe, card, clientSecret)
  })
})

import { loadStripe } from '@stripe/stripe-js'
import 'PaymentGateways/stripe/styles/stripe.scss'

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

document.addEventListener('DOMContentLoaded', async () => {
  const dataset = (document.querySelector('.stripe-form') as HTMLElement).dataset
  const stripePublishableKey = dataset.publishableKey || ''
  const clientSecret = dataset.clientSecret || ''
  const form = document.querySelector('#payment-form') as HTMLFormElement
  const callbackForm = document.querySelector('#payment-callback-form') as HTMLFormElement
  const payButton = document.querySelector('#submit-payment') as HTMLButtonElement
  const cardError = document.querySelector('#card-error') as HTMLElement
  const errorMsg = document.querySelector('#card-error') as HTMLElement
  const spinner = document.querySelector('#spinner') as HTMLElement
  const buttonText = document.querySelector('#button-text') as HTMLElement

  const stripe = await loadStripe(stripePublishableKey) as Stripe
  const elements = stripe.elements()
  const card = elements.create('card', { style })

  const payWithCard = (stripe: Stripe, card: StripeCardElement, clientSecret: string) => {
    setLoading(true)
    stripe.confirmCardPayment(clientSecret, {
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
      hiddenField.value = (paymentIntent as any)[key]
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
    cardError.textContent = event.error?.message || ''
  })
  form.addEventListener('submit', function (event) {
    event.preventDefault()
    payWithCard(stripe, card, clientSecret)
  })
})

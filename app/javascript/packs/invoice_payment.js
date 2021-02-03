import { loadStripe } from '@stripe/stripe-js'
import 'PaymentGateways/stripe/styles/stripe.scss'

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
  const dataset = document.querySelector('.stripe-form').dataset
  const stripePublishableKey = dataset.publishableKey
  const clientSecret = dataset.clientSecret
  const form = document.querySelector('#payment-form')
  const callbackForm = document.querySelector('#payment-callback-form')
  const payButton = document.querySelector('#submit-payment')
  const cardError = document.querySelector('#card-error')
  const errorMsg = document.querySelector('#card-error')
  const spinner = document.querySelector('#spinner')
  const buttonText = document.querySelector('#button-text')

  const stripe = await loadStripe(stripePublishableKey)
  const elements = stripe.elements()
  const card = elements.create('card', { style })

  const payWithCard = (stripe, card, clientSecret) => {
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

  const orderComplete = (paymentIntent) => {
    Object.keys(paymentIntent).forEach(key => {
      const hiddenField = document.createElement('input')
      hiddenField.type = 'hidden'
      hiddenField.name = `payment_intent[${key}]`
      hiddenField.value = paymentIntent[key]
      callbackForm.appendChild(hiddenField)
    })
    callbackForm.submit()
  }

  const showError = (errorMsgText) => {
    setLoading(false)
    errorMsg.textContent = errorMsgText
    setTimeout(() => {
      errorMsg.textContent = ''
    }, 4000)
  }

  const setLoading = (isLoading) => {
    payButton.disabled = isLoading
    spinner.classList.toggle('hidden', !isLoading)
    buttonText.classList.toggle('hidden', isLoading)
  }

  payButton.disabled = true
  card.mount('#card-element')
  card.on('change', event => {
    payButton.disabled = !event.complete
    cardError.textContent = event.error ? event.error.message : ''
  })
  form.addEventListener('submit', function (event) {
    event.preventDefault()
    payWithCard(stripe, card, clientSecret)
  })
})

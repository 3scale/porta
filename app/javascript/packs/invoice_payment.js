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
  const stripePublishableKey = document.querySelector('.stripe-form').dataset.publishableKey
  const clientSecret = document.querySelector('.stripe-form').dataset.clientSecret
  const form = document.querySelector('#payment-form')
  const payButton = document.querySelector('#submit-payment')
  const cardError = document.querySelector('#card-error')
  const resultMessage = document.querySelector('.result-message')
  const resultMessageLink = document.querySelector('.result-message a')
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
        orderComplete(result.paymentIntent.id)
      }
    })
  }

  const orderComplete = (paymentIntentId) => {
    setLoading(false)
    resultMessageLink.setAttribute(
      'href',
      'https://dashboard.stripe.com/test/payments/' + paymentIntentId
    )
    resultMessage.classList.remove('hidden')
    payButton.disabled = true
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

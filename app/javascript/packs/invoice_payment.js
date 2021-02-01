import { loadStripe } from '@stripe/stripe-js'
import 'PaymentGateways/stripe/styles/stripe.scss'

document.addEventListener('DOMContentLoaded', async () => {
  const stripePublishableKey = document.querySelector('.stripe-form').dataset.publishableKey
  const clientSecret = document.querySelector('.stripe-form').dataset.clientSecret
  if (!stripePublishableKey || !clientSecret) {
    return
  }

  const payButton = document.querySelector('#submit-payment')

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

  const payWithCard = function (stripe, card, clientSecret) {
    loading(true)
    stripe
      .confirmCardPayment(clientSecret, {
        payment_method: {
          card: card
        }
      })
      .then(function (result) {
        if (result.error) {
          showError(result.error.message)
        } else {
          orderComplete(result.paymentIntent.id)
        }
      })
  }

  var orderComplete = function (paymentIntentId) {
    loading(false)
    document
      .querySelector('.result-message a')
      .setAttribute(
        'href',
        'https://dashboard.stripe.com/test/payments/' + paymentIntentId
      )
    document.querySelector('.result-message').classList.remove('hidden')
    payButton.disabled = true
  }

  const showError = function (errorMsgText) {
    loading(false)
    var errorMsg = document.querySelector('#card-error')
    errorMsg.textContent = errorMsgText
    setTimeout(function () {
      errorMsg.textContent = ''
    }, 4000)
  }

  const loading = function (isLoading) {
    if (isLoading) {
      payButton.disabled = true
      document.querySelector('#spinner').classList.remove('hidden')
      document.querySelector('#button-text').classList.add('hidden')
    } else {
      payButton.disabled = false
      document.querySelector('#spinner').classList.add('hidden')
      document.querySelector('#button-text').classList.remove('hidden')
    }
  }

  payButton.disabled = true
  const stripe = await loadStripe(stripePublishableKey)
  const elements = stripe.elements()
  const card = elements.create('card', { style: style })
  card.mount('#card-element')
  card.on('change', function (event) {
    payButton.disabled = event.empty
    document.querySelector('#card-error').textContent = event.error ? event.error.message : ''
  })
  const form = document.getElementById('payment-form')
  form.addEventListener('submit', function (event) {
    event.preventDefault()
    payWithCard(stripe, card, clientSecret)
  })
})

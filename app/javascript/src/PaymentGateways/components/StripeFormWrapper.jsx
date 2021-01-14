// @flow

import React, { useState } from 'react'
import {loadStripe} from '@stripe/stripe-js'
import {Elements, CardElement, useStripe, useElements} from '@stripe/react-stripe-js'
import {createReactWrapper} from 'utilities/createReactWrapper'
import {CSRFToken} from 'utilities/utils'
import 'PaymentGateways/styles/stripe.scss'

type Props = {
  stripePublishableKey: string,
  setupIntentSecret: string,
  billingAddressDetails: {
    line1: string,
    line2: string,
    city: string,
    state: string,
    postal_code: string,
    country: string
  },
  successUrl: string,
  isCreditCardStored: boolean
}

const EditCreditCardDetails = ({isCreditCardStored}: {isCreditCardStored: boolean}) => {
  const [state, setState] = useState<{isStripeFormVisible: boolean}>({ isStripeFormVisible: !isCreditCardStored })

  const setStripeFormVisible = (isStripeFormVisible: boolean) => {
    setState(prevState => ({ ...prevState, isStripeFormVisible }))
  }

  const toggleStripeForm = () => {
    const newStateStripeFormVisible = !state.isStripeFormVisible
    const stripeForm = document.getElementById('stripe-form')
    newStateStripeFormVisible ? stripeForm.classList.remove('hidden') : stripeForm.classList.add('hidden')
    setStripeFormVisible(newStateStripeFormVisible)
  }

  return (
    <a className='card-on-file' onClick={toggleStripeForm}>
      <i className='fa fa-pencil'></i>
      <span>{state.isStripeFormVisible ? 'cancel' : 'Edit Credit Card Details'}</span>
    </a>
  )
}

const CreditCardErrors = ({cardErrorMessage}: {cardErrorMessage: null | string}) => {
  if (cardErrorMessage) {
    return (
      <span id='card-errors' role='alert'>
        {cardErrorMessage}
      </span>
    )
  } else {
    return (<div></div>)
  }
}

const StripeElementsForm = ({ stripePublishableKey, setupIntentSecret, billingAddressDetails, successUrl, isCreditCardStored }: Props) => {
  const stripePromise = loadStripe(stripePublishableKey)

  const CheckoutForm = () => {
    const stripe = useStripe()
    const elements = useElements()

    const [state, setState] = useState<{cardErrorMessage: null | string}>({ cardErrorMessage: null })

    const setCardErrorMessage = (cardErrorMessage: null | string) => {
      setState(prevState => ({ ...prevState, cardErrorMessage }))
    }

    const handleSubmit = async event => {
      event.preventDefault()

      setCardErrorMessage(null)

      const {error, setupIntent} = await stripe.confirmCardSetup(setupIntentSecret, {
        payment_method: {
          card: elements.getElement(CardElement),
          billing_details: {
            address: billingAddressDetails
          }
        }
      })

      if (setupIntent && setupIntent.status === 'succeeded') {
        document.getElementById('stripe_payment_method_id').value = setupIntent.payment_method
        document.getElementById('stripe-form').submit()
      } else {
        setCardErrorMessage(error.message)
      }
    }

    const CARD_OPTIONS = {
      iconStyle: 'solid',
      style: {
        base: {
          iconColor: '#8898AA',
          color: 'black',
          fontWeight: 300,
          fontFamily: '"Helvetica Neue", Helvetica, sans-serif',
          fontSize: '19px',
          '::placeholder': {
            color: '#3f454c'
          }
        },
        invalid: {
          iconColor: '#e85746',
          color: '#e85746'
        }
      },
      classes: {
        focus: 'is-focused',
        empty: 'is-empty'
      }
    }

    return (
      <div className='well StripeElementsForm'>
        <EditCreditCardDetails isCreditCardStored={isCreditCardStored} />
        <form onSubmit={handleSubmit} action={successUrl} id='stripe-form' acceptCharset='UTF-8' method='post' className={isCreditCardStored ? 'hidden' : 'card-missing'}>
          <fieldset>
            <legend>Credit card details</legend>
            <CardElement options={CARD_OPTIONS} className='col-md-10'/>
            <CreditCardErrors cardErrorMessage={state.cardErrorMessage} />
            <span id='card-errors' role='alert'></span>
          </fieldset>
          <fieldset>
            <div className='form-group'>
              <div className='col-md-10 operations'>
                <button type='submit' disabled={!stripe} className='btn btn-primary pull-right' id='stripe-submit'>
                  Save details
                </button>
              </div>
            </div>
          </fieldset>
          <input id='stripe_payment_method_id' name='stripe[payment_method_id]' type='hidden' value=''/>
          <CSRFToken/>
        </form>
      </div>
    )
  }

  return (
    <Elements stripe={stripePromise}>
      <CheckoutForm />
    </Elements>
  )
}

const StripeFormWrapper = (props: Props, containerId: string) => createReactWrapper(<StripeElementsForm {...props}/>, containerId)

export {
  StripeFormWrapper
}

// @flow

import React, { useState, useRef } from 'react'
import { useStripe, useElements, CardElement } from '@stripe/react-stripe-js'
import { CSRFToken } from 'utilities/utils'

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

const EditCreditCardDetails = ({ onToogleVisibility, isStripeFormVisible }: { onToogleVisibility: () => void, isStripeFormVisible: boolean }
) => (
  <a className='editCardButton' onClick={ onToogleVisibility }>
    <i className={ `fa fa-${isStripeFormVisible ? 'chevron-left' : 'pencil'}` }></i>
    <span>{ isStripeFormVisible ? 'cancel' : 'Edit Credit Card Details' }</span>
  </a>
)

const CreditCardErrors = ({ cardErrorMessage }: { cardErrorMessage: string }) => (
  <div class='cardErrors' role='alert'>
    { cardErrorMessage }
  </div>
)

const CardForm = ({ setupIntentSecret, billingAddressDetails, successUrl, isCreditCardStored }: { setupIntentSecret: string, billingAddressDetails: string, successUrl: string, isCreditCardStored: boolean }) => {
  // eslint-disable-next-line flowtype/no-weak-types
  const formRef: { current: any | HTMLFormElement } = useRef(null)
  const [cardErrorMessage, setCardErrorMessage] = useState(null)
  const [isStripeFormVisible, setIsStripeFormVisible] = useState(!isCreditCardStored)
  const [stripePaymentMethodId, setStripePaymentMethodId] = useState('')

  const stripe = useStripe()
  const elements = useElements()

  const toogleVisibility = () => setIsStripeFormVisible(!isStripeFormVisible)

  const handleSubmit = async event => {
    event.preventDefault()
    if (!stripe || !elements) {
      return
    }

    const { error, setupIntent } = await stripe.confirmCardSetup(setupIntentSecret, {
      payment_method: {
        card: elements.getElement(CardElement),
        billing_details: {
          address: billingAddressDetails
        }
      }
    })

    if (setupIntent && setupIntent.status === 'succeeded') {
      setStripePaymentMethodId(setupIntent.payment_method)
      formRef.current.submit()
    } else {
      setCardErrorMessage(error.message)
    }
  }

  return (
    <div className='well StripeElementsForm'>
      <EditCreditCardDetails
        onToogleVisibility={toogleVisibility}
        isStripeFormVisible={isStripeFormVisible}
      />
      <form
        onSubmit={handleSubmit}
        action={successUrl}
        id='stripe-form'
        acceptCharset='UTF-8'
        method='post'
        className={isStripeFormVisible ? '' : 'hidden'}
        ref={formRef}
      >
        <fieldset>
          <legend>Credit card details</legend>
          <CardElement options={CARD_OPTIONS} className='col-md-12' />
          { cardErrorMessage && <CreditCardErrors cardErrorMessage={ cardErrorMessage } /> }
        </fieldset>
        <fieldset>
          <div className='form-group'>
            <div className='col-md-10 operations'>
              <button
                type='submit'
                disabled={!stripe}
                className='btn btn-primary pull-right'
                id='stripe-submit'
              >
                Save details
              </button>
            </div>
          </div>
        </fieldset>
        <input
          id='stripe_payment_method_id'
          name='stripe[payment_method_id]'
          type='hidden'
          value={stripePaymentMethodId}
        />
        <CSRFToken />
      </form>
    </div>
  )
}

export { CardForm }

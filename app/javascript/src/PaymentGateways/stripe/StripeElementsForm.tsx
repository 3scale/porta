import { useState } from 'react'
import { CardElement, useElements, useStripe } from '@stripe/react-stripe-js'

import { CSRFToken } from 'utilities/CSRFToken'

import type { FormEventHandler, FunctionComponent } from 'react'
import type { StripeCardElementChangeEvent, StripeCardElementOptions } from '@stripe/stripe-js'
import type { BillingAddress } from 'PaymentGateways/stripe/types'

import './StripeElementsForm.scss'

const CARD_OPTIONS: StripeCardElementOptions = {
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

interface Props {
  setupIntentSecret: string;
  billingAddressDetails: BillingAddress;
  successUrl: string;
  isCreditCardStored: boolean;
}

const StripeElementsForm: FunctionComponent<Props> = ({
  setupIntentSecret,
  billingAddressDetails,
  successUrl,
  isCreditCardStored
}) => {
  const [cardHolderName, setCardHolderName] = useState('')
  const [cardErrorMessage, setCardErrorMessage] = useState<string>()
  const [isStripeFormVisible, setIsStripeFormVisible] = useState(!isCreditCardStored)
  const [cardElementComplete, setCardElementComplete] = useState(false)
  const [submitting, setSubmitting] = useState(false)

  const formComplete = cardElementComplete && cardHolderName.trim().length > 0

  const stripe = useStripe()
  const elements = useElements()

  const handleSubmit: FormEventHandler = async (event: React.MouseEvent<HTMLFormElement>) => {
    event.preventDefault()
    event.stopPropagation()

    if (!stripe || !elements || submitting || !formComplete) {
      return
    }

    setSubmitting(true)
    setCardErrorMessage(undefined)

    const form = event.currentTarget

    const { error, setupIntent } = await stripe.confirmCardSetup(setupIntentSecret, {
      // eslint-disable-next-line @typescript-eslint/naming-convention -- Stripe API
      payment_method: {
        // eslint-disable-next-line @typescript-eslint/no-non-null-assertion -- Let's assume it exists
        card: elements.getElement(CardElement)!,
        // eslint-disable-next-line @typescript-eslint/naming-convention -- Stripe API
        billing_details: {
          address: billingAddressDetails,
          email: '',
          name: cardHolderName,
          phone: ''
        }
      }
    })

    if (setupIntent && setupIntent.status === 'succeeded') {
      const input = form.elements.namedItem('stripe[payment_method_id]') as HTMLInputElement
      input.value = setupIntent.payment_method as string

      form.submit()
    } else {
      setCardErrorMessage(error?.message)
      setSubmitting(false)
    }
  }

  const validateCardElement = (event: StripeCardElementChangeEvent) => {
    setCardElementComplete(event.complete)
    setCardErrorMessage(event.error?.message)
  }

  return (
    <div className="well StripeElementsForm">
      <a className="editCardButton" onClick={() => { setIsStripeFormVisible(prev => !prev) }}>
        <i className={`fa fa-${isStripeFormVisible ? 'chevron-left' : 'pencil'}`} />
        <span>{isStripeFormVisible ? 'cancel' : 'Edit Credit Card Details'}</span>
      </a>
      <form
        acceptCharset="UTF-8"
        action={successUrl}
        className={isStripeFormVisible ? '' : 'hidden'}
        id="stripe-form"
        method="post"
        onSubmit={handleSubmit}
      >
        <fieldset>
          <legend>Credit card details</legend>
          <div className="col-md-12 StripeElement is-empty">
            <input
              className="fakeStripeElement col-md-12"
              placeholder="Cardholder name"
              value={cardHolderName}
              onChange={(e) => { setCardHolderName(e.currentTarget.value) }}
            />
          </div>
          <CardElement
            className="col-md-12"
            options={CARD_OPTIONS}
            onChange={validateCardElement}
          />
          {!!cardErrorMessage && <div className="cardErrors" role="alert">{cardErrorMessage}</div>}
        </fieldset>
        <fieldset>
          <div className="form-group">
            <div className="col-md-10 operations">
              <button
                className="btn btn-primary pull-right"
                disabled={!formComplete || submitting}
                id="stripe-submit"
                type="submit"
              >
                Save details
              </button>
            </div>
          </div>
        </fieldset>
        <input
          id="stripe_payment_method_id"
          name="stripe[payment_method_id]"
          type="hidden"
        />
        <CSRFToken />
      </form>
    </div>
  )
}

export { StripeElementsForm, Props }

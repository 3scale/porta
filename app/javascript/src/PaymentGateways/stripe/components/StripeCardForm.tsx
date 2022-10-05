/* eslint-disable react/no-multi-comp */
import { useRef, useState } from 'react'
import { CardElement, useElements, useStripe } from '@stripe/react-stripe-js'
import { CSRFToken } from 'utilities/CSRFToken'

import type { FormEventHandler, FunctionComponent, PropsWithChildren } from 'react'
import type { PaymentMethod, StripeCardElement, StripeCardElementChangeEvent, StripeCardElementOptions } from '@stripe/stripe-js'

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

const EditCreditCardDetails: FunctionComponent<{
  onToogleVisibility: () => void,
  isStripeFormVisible: boolean
}> = ({
  onToogleVisibility,
  isStripeFormVisible
}) => (
  <a className="editCardButton" onClick={onToogleVisibility}>
    <i className={`fa fa-${isStripeFormVisible ? 'chevron-left' : 'pencil'}`} />
    <span>{isStripeFormVisible ? 'cancel' : 'Edit Credit Card Details'}</span>
  </a>
)

const CreditCardErrors: FunctionComponent<PropsWithChildren> = ({ children }) => (
  <div className="cardErrors" role="alert">
    {children}
  </div>
)

type Props = {
  setupIntentSecret: string,
  billingAddressDetails: Record<any, any>,
  successUrl: string,
  isCreditCardStored: boolean
}

const StripeCardForm: FunctionComponent<Props> = ({
  setupIntentSecret,
  billingAddressDetails,
  successUrl,
  isCreditCardStored
}): React.ReactElement => {
  const formRef = useRef<HTMLFormElement | null>(null)
  const [cardErrorMessage, setCardErrorMessage] = useState<string | undefined>(undefined)
  const [isStripeFormVisible, setIsStripeFormVisible] = useState(!isCreditCardStored)
  const [stripePaymentMethodId, setStripePaymentMethodId] = useState<string | PaymentMethod | null>('')
  const [formComplete, setFormComplete] = useState(false)

  const stripe = useStripe()
  const elements = useElements()

  const toogleVisibility = () => setIsStripeFormVisible(!isStripeFormVisible)

  const handleSubmit: FormEventHandler = async (event) => {
    event.preventDefault()
    setFormComplete(false)

    if (!stripe || !elements) {
      return
    }

    const { error, setupIntent } = await stripe.confirmCardSetup(setupIntentSecret, {
      payment_method: {
        card: elements.getElement(CardElement) as StripeCardElement,
        billing_details: {
          address: billingAddressDetails
        }
      }
    })

    if (setupIntent && setupIntent.status === 'succeeded') {
      setStripePaymentMethodId(setupIntent.payment_method)
      formRef.current?.submit()
    } else {
      setCardErrorMessage(error && error.message)
    }
  }

  const validateCardElement = (event: StripeCardElementChangeEvent) => {
    setFormComplete(event.complete)
    setCardErrorMessage(event.error && event.error.message)
  }

  return (
    <div className='well StripeElementsForm'>
      <EditCreditCardDetails
        isStripeFormVisible={isStripeFormVisible}
        onToogleVisibility={toogleVisibility}
      />
      <form
        acceptCharset="UTF-8"
        action={successUrl}
        className={isStripeFormVisible ? '' : 'hidden'}
        id="stripe-form"
        method="post"
        ref={formRef}
        onSubmit={handleSubmit}
      >
        <fieldset>
          <legend>Credit card details</legend>
          <CardElement
            className="col-md-12"
            options={CARD_OPTIONS}
            onChange={validateCardElement}
          />
          {!!cardErrorMessage && <CreditCardErrors>{cardErrorMessage}</CreditCardErrors>}
        </fieldset>
        <fieldset>
          <div className="form-group">
            <div className="col-md-10 operations">
              <button
                className="btn btn-primary pull-right"
                disabled={!formComplete}
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
          value={stripePaymentMethodId ? stripePaymentMethodId.toString() : undefined}
        />
        <CSRFToken />
      </form>
    </div>
  )
}

export { StripeCardForm, Props }

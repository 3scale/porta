import { useRef, useState } from 'react'
import { CardElement, useElements, useStripe } from '@stripe/react-stripe-js'

import { CSRFToken } from 'utilities/CSRFToken'

import type { FormEventHandler, FunctionComponent, PropsWithChildren } from 'react'
import type { PaymentMethod, StripeCardElementChangeEvent, StripeCardElementOptions } from '@stripe/stripe-js'

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
  billingAddressDetails: Record<string, unknown>;
  successUrl: string;
  isCreditCardStored: boolean;
}

const StripeCardForm: FunctionComponent<Props> = ({
  setupIntentSecret,
  billingAddressDetails,
  successUrl,
  isCreditCardStored
}) => {
  const formRef = useRef<HTMLFormElement | null>(null)
  const [cardErrorMessage, setCardErrorMessage] = useState<string | undefined>(undefined)
  const [isStripeFormVisible, setIsStripeFormVisible] = useState(!isCreditCardStored)
  const [stripePaymentMethodId, setStripePaymentMethodId] = useState<PaymentMethod | string | null>('')
  const [formComplete, setFormComplete] = useState(false)

  const stripe = useStripe()
  const elements = useElements()

  const toggleVisibility = () => { setIsStripeFormVisible(!isStripeFormVisible) }

  const handleSubmit: FormEventHandler = async (event) => {
    event.preventDefault()
    setFormComplete(false)

    if (!stripe || !elements) {
      return
    }

    const { error, setupIntent } = await stripe.confirmCardSetup(setupIntentSecret, {
      // eslint-disable-next-line @typescript-eslint/naming-convention -- Stripe API
      payment_method: {
        // eslint-disable-next-line @typescript-eslint/no-non-null-assertion -- Let's assume it exists
        card: elements.getElement(CardElement)!,
        // eslint-disable-next-line @typescript-eslint/naming-convention -- Stripe API
        billing_details: {
          address: billingAddressDetails
        }
      }
    })

    if (setupIntent && setupIntent.status === 'succeeded') {
      setStripePaymentMethodId(setupIntent.payment_method)
      formRef.current?.submit()
    } else {
      setCardErrorMessage(error?.message)
    }
  }

  const validateCardElement = (event: StripeCardElementChangeEvent) => {
    setFormComplete(event.complete)
    setCardErrorMessage(event.error?.message)
  }

  return (
    <div className="well StripeElementsForm">
      <EditCreditCardDetails
        isStripeFormVisible={isStripeFormVisible}
        onToogleVisibility={toggleVisibility}
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
          value={stripePaymentMethodId?.toString()}
        />
        <CSRFToken />
      </form>
    </div>
  )
}

interface EditCreditCardDetailsProps {
  onToogleVisibility: () => void;
  isStripeFormVisible: boolean;
}

// eslint-disable-next-line react/no-multi-comp -- FIXME: move to its own file
const EditCreditCardDetails: FunctionComponent<EditCreditCardDetailsProps> = ({
  onToogleVisibility,
  isStripeFormVisible
}) => (
  <a className="editCardButton" onClick={onToogleVisibility}>
    <i className={`fa fa-${isStripeFormVisible ? 'chevron-left' : 'pencil'}`} />
    <span>{isStripeFormVisible ? 'cancel' : 'Edit Credit Card Details'}</span>
  </a>
)

// eslint-disable-next-line react/no-multi-comp -- FIXME: move to its own file
const CreditCardErrors: FunctionComponent<PropsWithChildren> = ({ children }) => (
  <div className="cardErrors" role="alert">
    {children}
  </div>
)

export { StripeCardForm, Props }

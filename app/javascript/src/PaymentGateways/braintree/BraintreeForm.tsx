import { useCallback, useRef, useState } from 'react'

import { CSRFToken } from 'utilities/CSRFToken'
import { createReactWrapper } from 'utilities/createReactWrapper'
import { validateForm } from 'PaymentGateways/braintree/utils/formValidation'
import { useBraintreeHostedFields } from 'PaymentGateways/braintree/utils/useBraintreeHostedFields'

import type { FunctionComponent } from 'react'
import type { BraintreeError } from 'braintree-web'
import type { BillingAddress, BraintreeFormDataset as Props } from 'PaymentGateways/braintree/types'

import './BraintreeCustomerForm.scss'

const CC_ERROR_MESSAGE = 'An error occurred, please review your CC details or try later.'

const BraintreeForm: FunctionComponent<Props> = ({
  billingAddress: defaultBillingAddress,
  clientToken,
  countriesList,
  formActionPath,
  threeDSecureEnabled = false
}) => {
  const formRef = useRef<HTMLFormElement>(null)

  const [billingAddress, setBillingAddress] = useState<BillingAddress>(defaultBillingAddress)
  const [submitting, setSubmitting] = useState(false)
  const [submitError, setSubmitError] = useState<BraintreeError>()

  const [hostedFields, hostedFieldsError, loading, valid] = useBraintreeHostedFields(clientToken, threeDSecureEnabled)

  const billingAddressErrors = validateForm(billingAddress)
  const submitDisabled = (hostedFields === undefined) || !valid || (billingAddressErrors !== undefined) || loading || submitting

  if (hostedFieldsError) {
    console.error('hostedFields threw an error:', hostedFieldsError)
  }

  if (submitError) {
    console.error('onSubmit threw an error:', submitError)
  }

  const onSubmit = useCallback((event: React.MouseEvent<HTMLButtonElement>) => {
    event.preventDefault()
    event.stopPropagation()

    if (!hostedFields || submitting) {
      return
    }

    setSubmitting(true)
    setSubmitError(undefined)

    hostedFields.getNonce(billingAddress)
      .then(nonce => {
        // eslint-disable-next-line @typescript-eslint/no-non-null-assertion -- Form will be there
        const form = formRef.current!
        const input = form.elements.namedItem('braintree[nonce]') as HTMLInputElement
        input.value = nonce

        form.submit()
      })
      .catch((error: BraintreeError) => {
        setSubmitError(error)
        setSubmitting(false)
      })
  }, [hostedFields, submitting, billingAddress])

  const { firstName, lastName, phone, company, address, zip, city, state, country } = billingAddress

  return (
    <form
      action={formActionPath}
      className="form-horizontal customer"
      ref={formRef}
    >
      <input name="utf8" type="hidden" value="✓" />
      <CSRFToken />
      <fieldset>
        <p className="required-fields">All fields marked with an asterisk ( * ) are mandatory</p>
        <ul className="list-unstyled">
          <li className="string optional form-group" id="customer_first_name_input">
            <label className="col-md-4 control-label" htmlFor="customer_first_name">
              First name *
            </label>
            <input
              required
              className="col-md-6 form-control"
              id="customer_first_name"
              name="customer[first_name]"
              value={firstName}
              onChange={({ currentTarget: { value } }) => { setBillingAddress(prev => ({ ...prev, firstName: value }) )}}
            />
          </li>
          <li className="string optional form-group" id="customer_last_name_input">
            <label className="col-md-4 control-label" htmlFor="customer_last_name">
              Last name *
            </label>
            <input
              required
              className="col-md-6 form-control"
              id="customer_last_name"
              name="customer[last_name]"
              value={lastName}
              onChange={({ currentTarget: { value } }) => { setBillingAddress(prev => ({ ...prev, lastName: value }) )}}
            />
          </li>
          <li className="string optional form-group" id="customer_phone_input">
            <label className="col-md-4 control-label" htmlFor="customer_phone">
              Phone *
            </label>
            <input
              className="col-md-6 form-control"
              id="customer_phone"
              name="customer[phone]"
              value={phone}
              onChange={({ currentTarget: { value } }) => { setBillingAddress(prev => ({ ...prev, phone: value }) )}}
            />
          </li>
        </ul>
      </fieldset>

      <fieldset disabled={!hostedFields}>
        <legend>Credit Card</legend>
        <ul className="list-unstyled">
          <li className="string optional form-group" id="customer_credit_card_number_input">
            <label className="col-md-4 control-label" htmlFor="customer_credit_card_number">
              Number *
            </label>
            <div className="form-control col-md-6" data-name="customer[credit_card][number]" id="customer_credit_card_number" />
          </li>

          <li className="string optional form-group" id="customer_credit_card_cvv_input">
            <label className="col-md-4 control-label" htmlFor="customer_credit_card_cvv">
              CVV *
            </label>
            <div className="form-control col-md-6" data-name="customer[credit_card][cvv]" id="customer_credit_card_cvv" />
          </li>

          <li className="string optional form-group" id="customer_credit_card_expiration_date_input">
            <label className="col-md-4 control-label" htmlFor="customer_credit_card_expiration_date">
              Expiration Date (MM/YY) *
            </label>
            <div className="form-control col-md-6" data-name="customer[credit_card][expiration_date]" id="customer_credit_card_expiration_date" />
          </li>

          {submitError && <p className="alert alert-danger">{CC_ERROR_MESSAGE}</p>}
        </ul>
      </fieldset>

      <fieldset>
        <legend>Billing address</legend>
        <ul className="list-unstyled">
          <li className="string optional form-group" id="customer_credit_card_billing_address_company_input">
            <label className="col-md-4 control-label" htmlFor="customer_credit_card_billing_address_company">
              Company *
            </label>
            <input
              required
              className="col-md-6 form-control"
              id="customer_credit_card_billing_address_company"
              name="customer[credit_card][billing_address][company]"
              value={company}
              onChange={({ currentTarget: { value } }) => { setBillingAddress(prev => ({ ...prev, company: value }) )}}
            />
          </li>
          <li className="string optional form-group" id="customer_credit_card_billing_address_street_address_input">
            <label className="col-md-4 control-label" htmlFor="customer_credit_card_billing_address_street_address">
              Street address *
            </label>
            <input
              required
              className="col-md-6 form-control"
              id="customer_credit_card_billing_address_street_address"
              name="customer[credit_card][billing_address][street_address]"
              value={address}
              onChange={({ currentTarget: { value } }) => { setBillingAddress(prev => ({ ...prev, address: value }) )}}
            />
          </li>
          <li className="string optional form-group" id="customer_credit_card_billing_address_postal_code_input">
            <label className="col-md-4 control-label" htmlFor="customer_credit_card_billing_address_postal_code">
              ZIP / Postal Code *
            </label>
            <input
              required
              className="col-md-6 form-control"
              id="customer_credit_card_billing_address_postal_code"
              name="customer[credit_card][billing_address][postal_code]"
              value={zip}
              onChange={({ currentTarget: { value } }) => { setBillingAddress(prev => ({ ...prev, zip: value }) )}}
            />
          </li>
          <li className="string optional form-group" id="customer_credit_card_billing_address_locality_input">
            <label className="col-md-4 control-label" htmlFor="customer_credit_card_billing_address_locality">
            City *
            </label>
            <input
              required
              className="col-md-6 form-control"
              id="customer_credit_card_billing_address_locality"
              name="customer[credit_card][billing_address][locality]"
              value={city}
              onChange={({ currentTarget: { value } }) => { setBillingAddress(prev => ({ ...prev, city: value }) )}}
            />
          </li>
          <li className="string optional form-group" id="customer_credit_card_billing_address_region_input">
            <label className="col-md-4 control-label" htmlFor="customer_credit_card_billing_address_region">
              State/Region
            </label>
            <input
              className="col-md-6 form-control"
              id="customer_credit_card_billing_address_region"
              name="customer[credit_card][billing_address][region]"
              value={state}
              onChange={({ currentTarget: { value } }) => { setBillingAddress(prev => ({ ...prev, state: value }) )}}
            />
            <div className="col-md-6 col-md-offset-4">
              The 2 letter code for US states or an ISO-3166-2 country subdivision code of up to three letters. <strong>If unsure, leave blank</strong>
            </div>
          </li>
          <li className="string optional form-group" id="customer_credit_card_billing_address_country_name_input">
            <label className="col-md-4 control-label" htmlFor="customer_credit_card_billing_address_country_name">
              Country *
            </label>
            <select
              required
              className="form-control col-md-6"
              id="customer_credit_card_billing_address_country_name"
              name="customer[credit_card][billing_address][country_name]"
              value={country}
              onChange={({ currentTarget: { value, selectedIndex } }) => {
                setBillingAddress(prev => ({
                  ...prev,
                  country: value,
                  countryCode: countriesList[selectedIndex - 1][1]
                }))
              }}
            >
              <option disabled value="" />
              {countriesList.map(([name, code]) => (
                <option key={code}>{name}</option>
              ))}
            </select>
          </li>
        </ul>
      </fieldset>

      <fieldset>
        <div className="form-group">
          <div className="col-md-10 operations">
            <button
              className="btn btn-primary pull-right"
              disabled={submitDisabled}
              type="submit"
              onClick={onSubmit}
            >
              Save details
            </button>
          </div>
        </div>
      </fieldset>

      <input id="braintree_nonce" name="braintree[nonce]" type="hidden" />
    </form>
  )
}

// eslint-disable-next-line react/jsx-props-no-spreading
const BraintreeFormWrapper = (props: Props, containerId: string): void => { createReactWrapper(<BraintreeForm {...props} />, containerId) }

export { BraintreeForm, BraintreeFormWrapper, Props }

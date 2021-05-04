import React from 'react'
import { Label } from 'PaymentGateways'

const BraintreeCardFields = () => {
  return (
    <>
      <legend>Credit Card</legend>
      <ul className="list-unstyled">
        <li
          id="customer_credit_card_number_input"
          className="string optional form-group"
        >
          <Label
            htmlFor="customer_credit_card_number"
            label="Number"
            required
          />
          <div
            id="customer_credit_card_number"
            className="form-control col-md-6"
            data-name="customer[credit_card][number]"
          ></div>
          <div className="col-md-6 col-md-offset-4 inline-hints">Should be a valid credit card number</div>
        </li>
        <li id="customer_credit_card_cvv_input"
          className="string optional form-group">
          <Label
            htmlFor="customer_credit_card_cvv"
            label="CVV"
            required
          />
          <div
            id="customer_credit_card_cvv"
            className="form-control col-md-6"
            data-name="customer[credit_card][cvv]"
          ></div>

        </li>
        <li id="customer_credit_card_expiration_date_input"
          className="string optional form-group">
          <Label
            htmlFor="customer_credit_card_expiration_date"
            label="Expiration Date (MM/YY)"
            required
          />
          <div
            id="customer_credit_card_expiration_date"
            className="form-control col-md-6"
            data-name="customer[credit_card][expiration_date]"
          ></div>
        </li>
      </ul>
    </>
  )
}

export { BraintreeCardFields }

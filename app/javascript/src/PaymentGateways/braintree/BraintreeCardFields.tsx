import React from 'react'
import type { ReactNode } from 'react'
import { Label, ListItem } from 'PaymentGateways'

const BraintreeCardFields = (): Node => {
  return (
    <>
      <legend>Credit Card</legend>
      <ul className="list-unstyled">
        <ListItem id="customer_credit_card_number_input">
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
          <div className="col-md-6 col-md-offset-4 inline-hints">Incorrect card number. Specify a valid credit card number</div>
        </ListItem>
        <ListItem id="customer_credit_card_cvv_input">
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

        </ListItem>
        <ListItem id="customer_credit_card_expiration_date_input">
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
        </ListItem>
      </ul>
    </>
  )
}

export { BraintreeCardFields }

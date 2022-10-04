import { Label, ListItem } from 'PaymentGateways'

import type { FunctionComponent } from 'react'

const BraintreeCardFields: FunctionComponent = () => {
  return (
    <>
      <legend>Credit Card</legend>
      <ul className="list-unstyled">
        <ListItem id="customer_credit_card_number_input">
          <Label
            required
            htmlFor="customer_credit_card_number"
            label="Number"
          />
          <div
            className="form-control col-md-6"
            data-name="customer[credit_card][number]"
            id="customer_credit_card_number"
          />
          <div className="col-md-6 col-md-offset-4 inline-hints">Incorrect card number. Specify a valid credit card number</div>
        </ListItem>
        <ListItem id="customer_credit_card_cvv_input">
          <Label
            required
            htmlFor="customer_credit_card_cvv"
            label="CVV"
          />
          <div
            className="form-control col-md-6"
            data-name="customer[credit_card][cvv]"
            id="customer_credit_card_cvv"
          />

        </ListItem>
        <ListItem id="customer_credit_card_expiration_date_input">
          <Label
            required
            htmlFor="customer_credit_card_expiration_date"
            label="Expiration Date (MM/YY)"
          />
          <div
            className="form-control col-md-6"
            data-name="customer[credit_card][expiration_date]"
            id="customer_credit_card_expiration_date"
          />
        </ListItem>
      </ul>
    </>
  )
}

export { BraintreeCardFields }

import React from 'react'

const BraintreeCardFields = () => {
  return (
    <>
      <legend>Credit Card</legend>
      <ul className="list-unstyled">
        <li
          id="customer_credit_card_number_input"
          className="string optional form-group"
        >
          <label htmlFor="customer_credit_card_number" className="col-md-4 control-label">Number *</label>
          <div
            id="customer_credit_card_number"
            className="form-control col-md-6"
            data-name="customer[credit_card][number]"
          ></div>
        </li>
        <li id="customer_credit_card_cvv_input"
          className="string optional form-group">
          <label
            htmlFor="customer_credit_card_cvv"
            className="col-md-4 control-label"
          >CVV *</label>
          <div
            id="customer_credit_card_cvv"
            className="form-control col-md-6"
            data-name="customer[credit_card][cvv]"
          ></div>
        </li>
        <li id="customer_credit_card_expiration_date_input"
          className="string optional form-group">
          <label
            htmlFor="customer_credit_card_expiration_date"
            className="col-md-4 control-label"
          >Expiration Date (MM/YY) *</label>
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

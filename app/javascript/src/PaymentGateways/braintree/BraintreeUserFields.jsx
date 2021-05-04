import React from 'react'
import { Label } from 'PaymentGateways'

const BraintreeUserFields = () => {
  return (
    <ul className="list-unstyled">
      <li
        id="customer_first_name_input"
        className="string optional form-group"
      >
        <Label
          htmlFor="customer_first_name"
          label="First name"
          required
        />
        <input
          id="customer_first_name"
          className="form-control col-md-6"
          type="text"
          required
          name="customer[first_name]"
        />
      </li>
      <li
        id="customer_last_name_input"
        className="string optional form-group"
      >
        <Label
          htmlFor="customer_last_name"
          label="Last name"
          required
        />
        <input
          id="customer_last_name"
          className="form-control col-md-6"
          type="text"
          required
          name="customer[last_name]"
        />
      </li>
      <li
        id="customer_phone_input"
        className="string optional form-group"
      >
        <Label
          htmlFor="customer_phone"
          label="Phone"
        />
        <input
          id="customer_phone"
          className="form-control col-md-6"
          type="text"
          name="Phone"
        />
      </li>
    </ul>
  )
}

export { BraintreeUserFields }

import React from 'react'

const BraintreeUserFields = () => {
  return (
    <ul className="list-unstyled">
      <li
        id="customer_first_name_input"
        className="string optional form-group"
      >
        <label
          htmlFor="customer_first_name"
          className="col-md-4 control-label"
        >First name
        </label>
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
        <label
          htmlFor="customer_last_name"
          className="col-md-4 control-label"
        >Last name
        </label>
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
        <label
          className="col-md-4 control-label">Phone</label>
        <input
          className="form-control col-md-6"
          type="text"
          name="Phone"
        />
      </li>
    </ul>
  )
}

export { BraintreeUserFields }

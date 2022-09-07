import React, {useState} from 'react';
import { Label, Input, ListItem } from 'PaymentGateways'
import type { ReactNode } from 'react'

const BraintreeUserFields = (): Node => {
  const [firstName, setFirstName] = useState('')
  const [lastName, setLastName] = useState('')
  const [phone, setPhone] = useState('')

  return (
    <ul className="list-unstyled">
      <ListItem id="customer_first_name_input">
        <Label
          htmlFor="customer_first_name"
          label="First name"
          required
        />
        <Input
          id="customer_first_name"
          name="customer[first_name]"
          value={firstName}
          onChange={(e) => setFirstName(e.currentTarget.value)}
          required
        />
      </ListItem>
      <ListItem id="customer_last_name_input">
        <Label
          htmlFor="customer_last_name"
          label="Last name"
          required
        />
        <Input
          id="customer_last_name"
          name="customer[last_name]"
          value={lastName}
          onChange={(e) => setLastName(e.currentTarget.value)}
          required
        />
      </ListItem>
      <ListItem id="customer_phone_input">
        <Label
          htmlFor="customer_phone"
          label="Phone"
          required
        />
        <Input
          id="customer_phone"
          name="customer[phone]"
          value={phone}
          onChange={(e) => setPhone(e.currentTarget.value)}
        />
      </ListItem>
    </ul>
  )
}

export { BraintreeUserFields }

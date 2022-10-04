import { useState } from 'react'
import { Input, Label, ListItem } from 'PaymentGateways'

import type { FunctionComponent } from 'react'

const BraintreeUserFields: FunctionComponent = () => {
  const [firstName, setFirstName] = useState('')
  const [lastName, setLastName] = useState('')
  const [phone, setPhone] = useState('')

  return (
    <ul className="list-unstyled">
      <ListItem id="customer_first_name_input">
        <Label
          required
          htmlFor="customer_first_name"
          label="First name"
        />
        <Input
          required
          id="customer_first_name"
          name="customer[first_name]"
          value={firstName}
          onChange={(e) => setFirstName(e.currentTarget.value)}
        />
      </ListItem>
      <ListItem id="customer_last_name_input">
        <Label
          required
          htmlFor="customer_last_name"
          label="Last name"
        />
        <Input
          required
          id="customer_last_name"
          name="customer[last_name]"
          value={lastName}
          onChange={(e) => setLastName(e.currentTarget.value)}
        />
      </ListItem>
      <ListItem id="customer_phone_input">
        <Label
          required
          htmlFor="customer_phone"
          label="Phone"
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

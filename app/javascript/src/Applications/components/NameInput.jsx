// @flow

import React from 'react'

import { FormGroup, TextInput } from '@patternfly/react-core'

type Props = {
  name: string,
  setName: string => void
}

const NameInput = ({ name, setName }: Props) => (
  <FormGroup
    label="Name"
    isRequired
    validated="default"
    fieldId="cinstance_name"
  >
    <TextInput
      type="text"
      id="cinstance_name"
      name="cinstance[name]"
      value={name}
      onChange={setName}
    />
  </FormGroup>
)

export { NameInput }

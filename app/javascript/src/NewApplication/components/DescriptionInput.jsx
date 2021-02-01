// @flow

import React from 'react'

import { FormGroup, TextInput } from '@patternfly/react-core'

type Props = {
  description: string,
  setDescription: string => void
}

const DescriptionInput = ({ description, setDescription }: Props) => (
  <FormGroup
    label="Description"
    validated="default"
    fieldId="cinstance_description"
  >
    <TextInput
      type="text"
      id="cinstance_description"
      name="cinstance[description]"
      value={description}
      onChange={setDescription}
    />
  </FormGroup>
)

export { DescriptionInput }

import * as React from 'react'

import { FormGroup, TextInput } from '@patternfly/react-core'

type Props = {
  name: string,
  setName: (name: string) => void
};

const NameInput = (
  {
    name,
    setName
  }: Props
): React.ReactElement => <FormGroup
  isRequired
  label="Name"
  validated="default"
  fieldId="backend_api_name"
>
  <TextInput
    type="text"
    id="backend_api_name"
    name="backend_api[name]"
    value={name}
    onChange={(value) => setName(value)}
  />
</FormGroup>

export { NameInput, Props }

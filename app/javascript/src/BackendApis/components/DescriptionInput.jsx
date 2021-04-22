// @flow

import * as React from 'react'

import { FormGroup, TextArea } from '@patternfly/react-core'

type Props = {
  description: string,
  setDescription: string => void
}

const DescriptionInput = ({ description, setDescription }: Props): React.Node => (
  <FormGroup
    label="Description"
    validated="default"
    fieldId="backend_api_description"
  >
    <TextArea
      id="backend_api_description"
      description="backend_api[description]"
      value={description}
      onChange={setDescription}
    />
  </FormGroup>
)

export { DescriptionInput }

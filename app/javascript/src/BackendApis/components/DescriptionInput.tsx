import { FormGroup, TextArea } from '@patternfly/react-core'

import type { FunctionComponent } from 'react'

interface Props {
  description: string;
  setDescription: (description: string) => void;
}

const DescriptionInput: FunctionComponent<Props> = ({
  description,
  setDescription
}) => (
  <FormGroup
    fieldId="backend_api_description"
    label="Description"
    validated="default"
  >
    <TextArea
      id="backend_api_description"
      name="backend_api[description]"
      value={description}
      onChange={setDescription}
    />
  </FormGroup>
)

export type { Props }
export { DescriptionInput }

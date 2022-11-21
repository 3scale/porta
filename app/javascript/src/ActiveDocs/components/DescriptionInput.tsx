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
    fieldId="api_docs_service_description"
    label="Description"
    validated="default"
  >
    <TextArea
      id="api_docs_service_description"
      name="api_docs_service[description]"
      value={description}
      onChange={setDescription}
    />
  </FormGroup>
)

export { DescriptionInput, Props }

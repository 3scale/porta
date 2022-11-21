import { FormGroup, TextArea } from '@patternfly/react-core'

import type { FunctionComponent } from 'react'

interface Props {
  apiJsonSpec: string;
  setApiJsonSpec: (description: string) => void;
}

const ApiJsonSpecInput: FunctionComponent<Props> = ({
  apiJsonSpec,
  setApiJsonSpec
}) => (
  <FormGroup
    fieldId="api_docs_service_body"
    label="Description"
    validated="default"
  >
    <TextArea
      id="api_docs_service_body"
      name="api_docs_service[body]"
      value={apiJsonSpec}
      onChange={setApiJsonSpec}
    />
  </FormGroup>
)

export { ApiJsonSpecInput, Props }

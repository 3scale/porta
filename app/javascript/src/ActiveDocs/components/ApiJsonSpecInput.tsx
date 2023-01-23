import { FormGroup, TextArea } from '@patternfly/react-core'
// import { ExclamationCircleIcon } from '@patternfly/react-icons' add the icon when we upgrade to PF4

import type { FunctionComponent } from 'react'

import './ApiJsonSpecInput.scss'

interface Props {
  apiJsonSpec: string;
  setApiJsonSpec: (description: string) => void;
  errors?: string[];
}

const ApiJsonSpecInput: FunctionComponent<Props> = ({
  apiJsonSpec,
  setApiJsonSpec,
  errors = []
}) => {
  
  const validated = errors.length ? 'error' : 'default'

  return (
    <FormGroup
      fieldId="api_docs_service_body"
      helperText="Specification must comply with Swagger 1.2 2.0 or 3.0."
      helperTextInvalid={errors}
      // helperTextInvalidIcon={<ExclamationCircleIcon />} add the icon when we upgrade to PF4
      label="API JSON Spec"
      validated={validated}
    >
      <TextArea
        id="api_docs_service_body"
        name="api_docs_service[body]"
        validated={validated}
        value={apiJsonSpec}
        onChange={setApiJsonSpec}
      />
    </FormGroup>
  )
}

export { ApiJsonSpecInput, Props }

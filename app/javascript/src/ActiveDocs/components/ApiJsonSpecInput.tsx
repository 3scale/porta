import { FormGroup, TextArea } from '@patternfly/react-core'

import { useCodeMirror } from 'ActiveDocs/useCodeMirror'
// import { ExclamationCircleIcon } from '@patternfly/react-icons' add the icon when we upgrade to PF4

import type { FunctionComponent } from 'react'

import './ApiJsonSpecInput.scss'

interface Props {
  apiJsonSpec: string;
  errors?: string[];
  setApiJsonSpec: (description: string) => void;
}

const ApiJsonSpecInput: FunctionComponent<Props> = ({
  apiJsonSpec,
  errors = [],
  setApiJsonSpec
}) => {
  const textAreaId = 'api_docs_service_body'
  const validated = errors.length ? 'error' : 'default'

  useCodeMirror(textAreaId, apiJsonSpec, setApiJsonSpec)

  return (
    <FormGroup
      isRequired
      fieldId="api_docs_service_body"
      helperText="Specification must comply with Swagger 1.2 2.0 or 3.0."
      helperTextInvalid={errors}
      // helperTextInvalidIcon={<ExclamationCircleIcon />} add the icon when we upgrade to PF4
      label="API JSON Spec"
      validated={validated}
    >
      <TextArea
        id={textAreaId}
        name="api_docs_service[body]"
        validated={validated}
      />
    </FormGroup>
  )
}

export type { Props }
export { ApiJsonSpecInput }

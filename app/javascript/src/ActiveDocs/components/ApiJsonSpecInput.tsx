import { FormGroup, TextArea } from '@patternfly/react-core'
import ExclamationCircleIcon from '@patternfly/react-icons/dist/js/icons/exclamation-circle-icon'

import { useCodeMirror } from 'ActiveDocs/useCodeMirror'

import type { FunctionComponent } from 'react'

import './ApiJsonSpecInput.scss'

interface Props {
  apiJsonSpec: string;
  errors?: string[];
  setApiJsonSpec: (description: string) => void;
}

const emptyArray = [] as never[]

const ApiJsonSpecInput: FunctionComponent<Props> = ({
  apiJsonSpec,
  errors = emptyArray,
  setApiJsonSpec
}) => {
  const textAreaId = 'api_docs_service_body'
  const validated = errors.length ? 'error' : 'default'

  useCodeMirror(textAreaId, apiJsonSpec, setApiJsonSpec)

  return (
    <FormGroup
      isRequired
      fieldId="api_docs_service_body"
      helperText={(
        <>
        Specification must comply with Swagger <a href="https://github.com/swagger-api/swagger-spec/blob/master/versions/1.2.md#52-api-declaration">1.2</a>, <a href="https://github.com/swagger-api/swagger-spec/blob/master/versions/2.0.md">2.0</a> or <a href="https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.2.md">3.0</a>
        </>
      )}
      helperTextInvalid={errors}
      helperTextInvalidIcon={<ExclamationCircleIcon />}
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

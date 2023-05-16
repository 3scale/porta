import { FormGroup, TextArea } from '@patternfly/react-core'

import type { FunctionComponent } from 'react'

interface Props {
  description: string;
  errors?: string[];
  setDescription: (description: string) => void;
}

const emptyStringArray: string[] = []

const DescriptionInput: FunctionComponent<Props> = ({
  description,
  errors = emptyStringArray,
  setDescription
}) => {
  
  const validated = errors.length ? 'error' : 'default'

  return (
    <FormGroup
      fieldId="api_docs_service_description"
      helperTextInvalid={errors}
      // helperTextInvalidIcon={<ExclamationCircleIcon />} add the icon when we upgrade to PF4
      label="Description"
      validated={validated}
    >
      <TextArea
        id="api_docs_service_description"
        name="api_docs_service[description]"
        validated={validated}
        value={description} 
        onChange={setDescription}
      />
    </FormGroup>
  )
}

export type { Props }
export { DescriptionInput }

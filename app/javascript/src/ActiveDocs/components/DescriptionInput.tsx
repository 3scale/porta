import { FormGroup, TextArea } from '@patternfly/react-core'

import type { FunctionComponent } from 'react'

interface Props {
  description: string;
  setDescription: (description: string) => void;
  errors?: string[];
}

const DescriptionInput: FunctionComponent<Props> = ({
  description,
  setDescription,
  errors = []
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

export { DescriptionInput, Props }

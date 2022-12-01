import { FormGroup, TextInput } from '@patternfly/react-core'
// import { ExclamationCircleIcon } from '@patternfly/react-icons' add the icon when we upgrade to PF4

import type { FunctionComponent } from 'react'

interface Props {
  name: string;
  setName: (name: string) => void;
  errors?: string[];
}

const NameInput: FunctionComponent<Props> = ({ name, setName, errors = [] }) => {    

  const validated = errors.length ? 'error' : 'default'

  return (
    <FormGroup
      isRequired
      fieldId="api_docs_service_name"
      helperTextInvalid={errors}
      // helperTextInvalidIcon={<ExclamationCircleIcon />} add the icon when we upgrade to PF4
      label="Name"
      validated={validated}
    >
      <TextInput
        id="api_docs_service_name"
        name="api_docs_service[name]"
        type="text"
        validated={validated}
        value={name}
        onChange={setName}
      />
    </FormGroup>
  )
}

export { NameInput, Props }

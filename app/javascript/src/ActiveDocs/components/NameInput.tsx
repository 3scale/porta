import { FormGroup, TextInput } from '@patternfly/react-core'
// import ExclamationCircleIcon from '@patternfly/react-icons/dist/js/icons/exclamation-circle-icon' add the icon when we upgrade to PF4

import type { FunctionComponent } from 'react'

interface Props {
  errors?: string[];
  name: string;
  setName: (name: string) => void;
}

const emptyStringArray: string[] = []

const NameInput: FunctionComponent<Props> = ({ errors = emptyStringArray, name, setName }) => {
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

export type { Props }
export { NameInput }

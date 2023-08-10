import { FormGroup, TextInput } from '@patternfly/react-core'
import ExclamationCircleIcon from '@patternfly/react-icons/dist/js/icons/exclamation-circle-icon'

import type { FunctionComponent } from 'react'

interface Props {
  errors?: string[];
  name: string;
  setName: (name: string) => void;
}

const emptyArray = [] as never[]

const NameInput: FunctionComponent<Props> = ({ errors = emptyArray, name, setName }) => {
  const validated = errors.length ? 'error' : 'default'

  return (
    <FormGroup
      isRequired
      fieldId="api_docs_service_name"
      helperTextInvalid={errors}
      helperTextInvalidIcon={<ExclamationCircleIcon />}
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

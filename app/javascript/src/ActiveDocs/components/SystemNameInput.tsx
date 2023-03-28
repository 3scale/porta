import { FormGroup, TextInput, Alert } from '@patternfly/react-core'

import { FormAlert } from 'ActiveDocs/components/FormAlert'

import type { FunctionComponent } from 'react'

import './SystemNameInput.scss'

interface Props {
  errors?: string[];
  isDisabled?: boolean;
  setSystemName: (systemName: string) => void;
  systemName: string;
}

const SystemNameInput: FunctionComponent<Props> = ({ errors = [], isDisabled = false, setSystemName, systemName }) => {
  const validated = errors.length ? 'error' : 'default'

  return (
    <FormGroup
      fieldId="api_docs_service_system_name"
      helperText={(
        <>
          Only ASCII letters, numbers, dashes and underscores are allowed.
          <FormAlert>
            <Alert
              isInline 
              title={(
                <span>Warning: With ActiveDocs 1.2 the API will be described in your developer portal as <i>System name: Description</i></span>
              )} 
              variant="warning"
            />
          </FormAlert>
        </>
      )}
      helperTextInvalid={errors}
      label="System name"
      validated={validated}
    >
      <TextInput
        id="api_docs_service_system_name"
        isDisabled={isDisabled}
        name="api_docs_service[system_name]"
        type="text"
        validated={validated}
        value={systemName}
        onChange={setSystemName}
      />
    </FormGroup>
  )
}

export type { Props }
export { SystemNameInput }

import { useState } from 'react'
import { ActionGroup, Button, Form } from '@patternfly/react-core'
import validate from 'validate.js'
import { NameInput } from 'BackendApis/components/NameInput'
import { SystemNameInput } from 'BackendApis/components/SystemNameInput'
import { DescriptionInput } from 'BackendApis/components/DescriptionInput'
import { PrivateEndpointInput } from 'BackendApis/components/PrivateEndpointInput'
import { CSRFToken } from 'utilities/CSRFToken'

import type { FunctionComponent } from 'react'
import type { ValidationErrors } from 'Types'

interface Props {
  action: string;
  onCancel: () => void;
  isLoading?: boolean;
  errors?: {
    // eslint-disable-next-line @typescript-eslint/naming-convention -- Comes from rails like that
    private_endpoint: string[];
  };
}

const VALIDATION_CONSTRAINTS = {
  name: { presence: { allowEmpty: false } },
  // Regexp taken from app/lib/system_name.rb#L15
  systemName: { format: { pattern: /^(\w[\w\-/]+)?$/ } },
  // This does not mean to be exhaustive, let the server do the real validation
  privateEndpoint: { format: { pattern: /(https?|wss?):\/\/(www\.)?[-a-zA-Z0-9@:%._+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()!@:%_+.~#?&//=]*)/ } }
} as const

const NewBackendForm: FunctionComponent<Props> = ({
  action,
  onCancel,
  isLoading = false,
  errors // FIXME: no default {} means it will fail
}) => {
  const [name, setName] = useState('')
  const [systemName, setSystemName] = useState('')
  const [description, setDescription] = useState('')
  const [privateEndpoint, setPrivateEndpoint] = useState('')

  const validationErrors = validate({ name, systemName, privateEndpoint }, VALIDATION_CONSTRAINTS) as ValidationErrors

  return (
    <Form
      data-remote
      acceptCharset="UTF-8"
      action={action}
      id="new_backend_api_config"
      method="post"
      // isWidthLimited TODO: use when available instead of hardcoded css
    >
      <CSRFToken />
      <input name="utf8" type="hidden" value="✓" />

      <NameInput name={name} setName={setName} />
      <SystemNameInput setSystemName={setSystemName} systemName={systemName} />
      <DescriptionInput description={description} setDescription={setDescription} />
      <PrivateEndpointInput errors={errors?.private_endpoint} privateEndpoint={privateEndpoint} setPrivateEndpoint={setPrivateEndpoint} />

      <ActionGroup>
        <Button
          data-testid="newBackendCreateBackend-buttonSubmit"
          isDisabled={validationErrors !== undefined || isLoading}
          type="submit"
          variant="primary"
        >
          Create backend
        </Button>
        <Button
          data-testid="cancel"
          type="button"
          variant="secondary"
          onClick={onCancel}
        >
          Cancel
        </Button>
      </ActionGroup>
    </Form>
  )
}

export { NewBackendForm, Props }
